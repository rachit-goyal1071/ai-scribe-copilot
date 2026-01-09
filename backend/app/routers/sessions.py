import os
from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app import crud, schemas
from app.utils.audio import combine_chunks
from app.utils.storage import get_presigned_upload
from app.utils.transcription import transcribe_audio, generate_detailed_english_summary
from app import models

router = APIRouter(prefix="/v1", tags=["Sessions"])


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.post("/upload-session")
def upload_session(payload: schemas.SessionCreate, db: Session = Depends(get_db)):
    new_session = crud.create_session(db, payload)
    return {"id": new_session.id}


@router.post("/get-presigned-url")
def get_presigned(payload: dict):
    session_id = payload["sessionId"]
    chunk = payload["chunkNumber"]
    mime = payload["mimeType"]

    gcs_path = f"sessions/{session_id}/chunk_{chunk}.wav"

    signed_url, public_url = get_presigned_upload(gcs_path)

    return {
        "url": signed_url,
        "gcsPath": gcs_path,
        "publicUrl": public_url
    }



@router.get("/all-session")
def all_session(userId: str, db: Session = Depends(get_db)):
    sessions = crud.get_sessions_for_user(db, userId)
    patient_ids = [s.patient_id for s in sessions]

    patient_map = {}
    for pid in set(patient_ids):
        p = crud.get_patient(db, pid)
        if p:
            patient_map[pid] = {"name": p.name, "pronouns": p.pronouns}

    return {
        "sessions": sessions,
        "patientMap": patient_map
    }


@router.post("/notify-chunk-uploaded")
def notify(payload: dict, background: BackgroundTasks, db: Session = Depends(get_db)):

    # 1. Save chunk to DB
    crud.add_chunk(db, payload)

    # 2. Get all chunks
    chunks = crud.get_chunks_for_session(db, payload["sessionId"])

    uploaded = len(chunks)
    expected = payload["totalChunksClient"]

    if uploaded < expected:
        return {
            "status": "waiting",
            "uploaded": uploaded,
            "expected": expected
        }

    # 3. All chunks received → Set to "processing"
    session = db.query(models.Session).filter(models.Session.id == payload["sessionId"]).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    session.status = "processing"
    db.commit()

    # 4. Launch background job (use its own DB session)
    background.add_task(process_session_audio, payload["sessionId"])

    return {"status": "processing_started"}


def process_session_audio(session_id: str):
    """Background pipeline:
    - Combine chunks
    - Transcribe audio
    - Generate English detailed summary
    - Save transcript+summary
    - Mark session as completed/failed

    Note: This function manages its own DB session.
    """
    print(f"[PIPELINE] Starting processing for {session_id}")

    db_session = SessionLocal()
    try:
        session = db_session.query(models.Session).filter(models.Session.id == session_id).first()
        if not session:
            print(f"[PIPELINE] Session not found: {session_id}")
            return

        # Avoid double-processing if multiple notify calls arrive
        if session.status == "completed" and session.session_summary:
            print(f"[PIPELINE] Session {session_id} already completed; skipping reprocessing")
            return

        # Clear previous error (if any)
        session.session_error = None
        db_session.commit()

        # 1. Fetch chunks
        chunks = crud.get_chunks_for_session(db_session, session_id)
        print(f"[PIPELINE] chunks={len(chunks)} for {session_id}")
        if not chunks:
            session.status = "failed"
            session.session_error = "No chunks found for session"
            db_session.commit()
            print(f"[PIPELINE] No chunks found for {session_id}")
            return

        # 2. Combine chunks
        combined_path = combine_chunks(session_id, chunks)
        print(f"[PIPELINE] combined wav: {combined_path}")

        # 3. Transcribe using OpenAI (force English output)
        transcript_text = transcribe_audio(combined_path, language="en")
        print(f"[PIPELINE] transcript chars={len(transcript_text or '')}")

        # 4. Generate a fully-detailed English summary (always English)
        detailed_summary = generate_detailed_english_summary(transcript_text)
        print(f"[PIPELINE] summary chars={len(detailed_summary or '')}")

        # 5. Save transcript + summary
        session.transcript = transcript_text
        session.session_summary = detailed_summary
        session.status = "completed"
        db_session.commit()

        print(
            f"[PIPELINE] Session {session_id} transcription+summary completed. "
            f"transcript_chars={len(transcript_text or '')} summary_chars={len(detailed_summary or '')}"
        )

    except Exception as e:
        # Best-effort failure marking
        try:
            session = db_session.query(models.Session).filter(models.Session.id == session_id).first()
            if session:
                session.status = "failed"
                session.session_error = str(e)
                db_session.commit()
        except Exception:
            pass

        print(f"[PIPELINE] Session {session_id} processing failed: {e}")

    finally:
        db_session.close()


@router.get("/session-transcript/{session_id}")
def get_session_transcript(session_id: str, db: Session = Depends(get_db)):
    session = db.query(models.Session).filter(models.Session.id == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    return {
        # snake_case (matches SessionModel.fromJson currently)
        "transcript": session.transcript,
        "session_summary": session.session_summary,
        "status": session.status,
        "session_error": getattr(session, "session_error", None),
        # camelCase convenience
        "sessionTranscript": session.transcript,
        "sessionSummary": session.session_summary,
        "sessionError": getattr(session, "session_error", None),
    }


@router.get("/session-audio/{session_id}", response_class=FileResponse)
def get_session_audio(session_id: str, db: Session = Depends(get_db)):
    # 1. Fetch chunks
    chunks = crud.get_chunks_for_session(db, session_id)
    print("CHUNKS FOUND:", len(chunks))
    for c in chunks:
        print(c.chunk_number, c.gcs_path)

    if not chunks or len(chunks) == 0:
        raise HTTPException(status_code=404, detail="No audio chunks found for this session.")

    # 2. Combine chunks into temp file
    try:
        combined_path = combine_chunks(session_id, chunks)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to combine chunks: {str(e)}")

    # 3. Return file
    # FileResponse automatically sets correct headers for download/stream
    response = FileResponse(
        combined_path,
        media_type="audio/wav",
        filename=f"{session_id}.wav"
    )

    # 4. Optional: remove file after response is sent
    # FastAPI workaround: background task
    from fastapi import BackgroundTasks
    def cleanup_file(path: str):
        if os.path.exists(path):
            os.remove(path)

    tasks = BackgroundTasks()
    tasks.add_task(cleanup_file, combined_path)
    response.background = tasks

    return response


@router.get("/debug/session/{session_id}")
def debug_session(session_id: str, db: Session = Depends(get_db)):
    """Debug endpoint to inspect stored session fields.

    Useful when the mobile client shows nulls and we need to confirm what is actually in DB.
    """
    session = db.query(models.Session).filter(models.Session.id == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    return {
        "id": session.id,
        "status": session.status,
        "transcript": session.transcript,
        "session_summary": session.session_summary,
        "session_error": getattr(session, "session_error", None),
    }
