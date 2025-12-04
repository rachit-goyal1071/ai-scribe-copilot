from pydantic import BaseModel
from typing import Optional, List

# ---------------- PATIENT ---------------- #

class PatientCreate(BaseModel):
    name: str
    userId: str


class Patient(BaseModel):
    id: str
    name: str
    user_id: str
    pronouns: Optional[str]

    class Config:
        orm_mode = True

class PatientResponse(BaseModel):
    patient: Patient
        


# ---------------- SESSION ---------------- #

class SessionCreate(BaseModel):
    patientId: str
    userId: str
    patientName: str
    status: str
    startTime: str
    templateId: str


class Session(BaseModel):
    id: str
    user_id: str
    patient_id: str
    session_title: Optional[str]
    session_summary: Optional[str]
    start_time: str
    end_time: Optional[str]
    transcript: Optional[str]

    class Config:
        orm_mode = True


# ---------------- TEMPLATE ---------------- #

class TemplateOut(BaseModel):
    id: str
    title: str
    type: str


class TemplateResponse(BaseModel):
    success: bool
    data: List[TemplateOut]
