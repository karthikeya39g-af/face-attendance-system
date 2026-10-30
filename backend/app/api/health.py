from fastapi import APIRouter, Depends, Request
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.security import require_api_key
from app.db.session import get_db

router = APIRouter()


@router.get("/health")
def health(request: Request):
    return {"status": "ok", "models_loaded": request.app.state.models.pipeline is not None}


@router.get("/api/system/models", dependencies=[Depends(require_api_key)])
def system_models(request: Request):
    return request.app.state.models.health()


@router.get("/api/system/database", dependencies=[Depends(require_api_key)])
def system_database(request: Request, db: Session = Depends(get_db)):
    db.execute(text("SELECT 1"))
    return {"database": "ok", "gallery_employees": len(request.app.state.matcher.entries)}
