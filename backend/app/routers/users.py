from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app import crud

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.get("/users/asd3fd2faec")
def resolve_user(email: str, db: Session = Depends(get_db)):
    print(email)
    user = crud.create_user_if_not_exists(db, email)
    return {"id": user.id}
