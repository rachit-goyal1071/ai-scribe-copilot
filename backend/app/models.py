from sqlalchemy import Column, String, Integer, Text, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base

class User(Base):
    __tablename__ = "users"
    id = Column(String, primary_key=True)
    email = Column(String, unique=True)

class Patient(Base):
    __tablename__ = "patients"

    id = Column(String, primary_key=True)
    name = Column(String)
    user_id = Column(String)
    pronouns = Column(String)

class Session(Base):
    __tablename__ = "sessions"
    id = Column(String, primary_key=True)
    user_id = Column(String)
    patient_id = Column(String)
    status = Column(String)
    session_title = Column(String, nullable=True)
    session_summary = Column(Text, nullable=True)
    start_time = Column(String)
    end_time = Column(String, nullable=True)
    transcript = Column(Text, nullable=True)
    session_error = Column(Text, nullable=True)

class SessionChunk(Base):
    __tablename__ = "session_chunks"
    id = Column(String, primary_key=True)
    session_id = Column(String, ForeignKey("sessions.id"))
    chunk_number = Column(Integer)
    gcs_path = Column(String)     # still named gcs_path for spec compatibility
    public_url = Column(String)
    is_last = Column(Boolean, default=False)
