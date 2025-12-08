import uuid
from sqlalchemy.orm import Session
from app import models, schemas
from app.models import SessionChunk


# ---------------- USER ---------------- #

def get_user_by_email(db: Session, email: str):
    return db.query(models.User).filter(models.User.email == email).first()

def create_user_if_not_exists(db: Session, email: str):
    user = get_user_by_email(db, email)
    if user:
        return user

    new_user = models.User(id=str(uuid.uuid4()), email=email)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


# ---------------- PATIENT ---------------- #

def get_patients(db: Session, user_id: str):
    print(models.Patient.user_id)
    return db.query(models.Patient).filter(models.Patient.user_id == user_id).all()


def create_patient(db: Session, payload: schemas.PatientCreate):
    new_patient = models.Patient(
        id=str(uuid.uuid4()),
        name=payload.name,
        user_id=payload.userId,
        pronouns=None
    )
    db.add(new_patient)
    db.commit()
    db.refresh(new_patient)
    return new_patient


def get_patient(db: Session, patient_id: str):
    return db.query(models.Patient).filter(models.Patient.id == patient_id).first()


# ---------------- SESSION ---------------- #

def create_session(db: Session, payload: schemas.SessionCreate):
    new_session = models.Session(
        id=str(uuid.uuid4()),
        patient_id=payload.patientId,
        user_id=payload.userId,
        status=payload.status,
        start_time=payload.startTime,
        session_title=None,
        session_summary=None,
        transcript=None,
    )
    db.add(new_session)
    db.commit()
    db.refresh(new_session)
    return new_session


def get_sessions_for_patient(db: Session, patient_id: str):
    return db.query(models.Session).filter(models.Session.patient_id == patient_id).all()


def get_sessions_for_user(db: Session, user_id: str):
    return db.query(models.Session).filter(models.Session.user_id == user_id).all()

def add_chunk(db: Session, payload: dict):
    chunk = SessionChunk(
        id=str(uuid.uuid4()),
        session_id=payload["sessionId"],
        chunk_number=payload["chunkNumber"],
        gcs_path=payload["gcsPath"],
        public_url=payload["publicUrl"],
        is_last=payload["isLast"]
    )
    print(chunk)
    db.add(chunk)
    db.commit()
    db.refresh(chunk)
    return chunk


def get_chunks_for_session(db: Session, session_id: str):
    return (
        db.query(SessionChunk)
        .filter(SessionChunk.session_id == session_id)
        .order_by(SessionChunk.chunk_number.asc())
        .all()
    )