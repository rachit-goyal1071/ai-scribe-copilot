from fastapi import FastAPI
from app.routers import patients, sessions, templates, users

app = FastAPI()

app.include_router(patients.router)
app.include_router(sessions.router)
app.include_router(templates.router)
app.include_router(users.router)

@app.get("/")
def root():
    return {"status": "ok"}
