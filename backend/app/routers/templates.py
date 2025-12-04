from fastapi import APIRouter

router = APIRouter(prefix="/v1")

@router.get("/fetch-default-template-ext")
def fetch_templates(userId: str):
    return {"success": True, "data": []}
