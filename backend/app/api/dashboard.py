from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.core.security import require_api_key
from app.db.session import get_db
from app.services.dashboard_service import DashboardService

router = APIRouter(prefix="/api/dashboard", tags=["dashboard"], dependencies=[Depends(require_api_key)])


@router.get("/summary")
def summary(office: str | None = None, days: int = 14, db: Session = Depends(get_db), s: Settings = Depends(get_settings)):
    return DashboardService(s).summary(db, office, max(3, min(days, 90)))
