from datetime import date

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.deps import actor
from app.core.config import Settings, get_settings
from app.core.security import require_api_key
from app.db.models import LeaveType
from app.db.session import get_db
from app.services.leave_service import LeaveError, LeaveService

router = APIRouter(prefix="/api/leave", tags=["leave"], dependencies=[Depends(require_api_key)])


class LeaveIn(BaseModel):
    employee_code: str
    leave_type: str
    start_date: date
    end_date: date
    reason: str | None = None


def run(fn, *a):
    try:
        return fn(*a)
    except LeaveError as e:
        raise HTTPException(e.status, {"error": e.code, "message": e.message})


@router.get("/types")
def types(db: Session = Depends(get_db)):
    return [{"code": t.code, "name": t.name, "paid": t.is_paid} for t in db.scalars(select(LeaveType).order_by(LeaveType.id))]


@router.get("/requests")
def requests(status: str | None = None, employee_code: str | None = None, db: Session = Depends(get_db),
             s: Settings = Depends(get_settings)):
    return LeaveService(s).list(db, status, employee_code)


@router.post("/requests", status_code=201)
def create(body: LeaveIn, db: Session = Depends(get_db), s: Settings = Depends(get_settings)):
    svc = LeaveService(s)
    return svc.to_dict(run(svc.create, db, body.employee_code, body.leave_type, body.start_date, body.end_date, body.reason))


@router.post("/requests/{request_id}/{action}")
def decide(request_id: int, action: str, db: Session = Depends(get_db), s: Settings = Depends(get_settings),
           who: str = Depends(actor)):
    if action not in ("approve", "reject", "cancel"):
        raise HTTPException(404, {"error": "unknown_action"})
    svc = LeaveService(s)
    return svc.to_dict(run(svc.decide, db, request_id, action, who))
