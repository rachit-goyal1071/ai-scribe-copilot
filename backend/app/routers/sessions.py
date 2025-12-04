from fastapi import APIRouter, BackgroundTasks, Depends
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app import crud, schemas
from app.utils.audio import combine_chunks
from app.utils.storage import get_presigned_upload
from app.utils.transcription import transcribe_audio
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


@router.post("/notify-chunk-uploaded")
def notify(payload: dict):
    return {}


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
    session.status = "processing"
    db.commit()

    # 4. Launch background job
    background.add_task(process_session_audio, payload["sessionId"], db)

    return {"status": "processing_started"}

def process_session_audio(session_id: str, db_session):
    """
    This runs asynchronously:
    - Combine chunks
    - Transcribe audio
    - Save transcript
    - Mark session as completed
    """
    print(f"[PIPELINE] Starting processing for {session_id}")

    # 1. Fetch chunks again
    chunks = crud.get_chunks_for_session(db_session, session_id)

    # 2. Combine chunks
    combined_path = combine_chunks(session_id, chunks)

    # 3. Transcribe using OpenAI
    transcript_text = transcribe_audio(combined_path)

    # 4. Save transcript in session DB
    session = db_session.query(models.Session).filter(models.Session.id == session_id).first()
    session.transcript = transcript_text
    session.status = "completed"
    db_session.commit()

    print(f"[PIPELINE] Session {session_id} transcription completed.")
