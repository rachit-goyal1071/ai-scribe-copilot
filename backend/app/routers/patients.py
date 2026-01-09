from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app import crud, schemas

router = APIRouter(prefix="/v1", tags=["Patients"])


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.get("/patients")
def get_patients(userId: str, db: Session = Depends(get_db)):
    print("🔥 userId received by FastAPI =", userId)
    patients = crud.get_patients(db, userId)
    return {"patients": patients}


@router.post(
    "/add-patient-ext",
    response_model=schemas.PatientResponse
)
def add_patient(payload: schemas.PatientCreate, db: Session = Depends(get_db)):
    created = crud.create_patient(db, payload)
    return {"patient": created}



@router.get("/patient-details/{patientId}")
def patient_details(patientId: str, db: Session = Depends(get_db)):
    patient = crud.get_patient(db, patientId)
    return patient


@router.get("/fetch-session-by-patient/{patientId}")
def fetch_session(patientId: str, db: Session = Depends(get_db)):
    sessions = crud.get_sessions_for_patient(db, patientId)

    # Serialize explicitly so keys match what the mobile client expects.
    sessions_out = [
        {
            "id": s.id,
            "user_id": s.user_id,
            "patient_id": s.patient_id,
            "status": s.status,
            "session_title": s.session_title,
            "session_summary": s.session_summary,
            "start_time": s.start_time,
            "end_time": s.end_time,
            "transcript": s.transcript,
        }
        for s in sessions
    ]

    return {"sessions": sessions_out}
