from fastapi import FastAPI
from app.routers import patients, sessions, templates, users

# Load local environment variables early (no-op if not present)
from dotenv import load_dotenv
load_dotenv()

app = FastAPI()

app.include_router(patients.router)
app.include_router(sessions.router)
app.include_router(templates.router)
app.include_router(users.router)

@app.get("/")
def root():
    return {"status": "ok"}
