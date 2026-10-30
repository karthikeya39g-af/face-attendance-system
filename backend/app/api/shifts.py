from datetime import date, time

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy import select, update
from sqlalchemy.orm import Session

from app.core.security import require_api_key
from app.db.models import Employee, EmployeeShift, Holiday, WorkShift
from app.db.session import get_db

router = APIRouter(prefix="/api", tags=["shifts"], dependencies=[Depends(require_api_key)])


class ShiftIn(BaseModel):
    name: str = Field(min_length=1, max_length=64)
    start_time: time
    end_time: time
    break_minutes: int = Field(60, ge=0, le=480)
    grace_minutes: int = Field(15, ge=0, le=180)
    required_hours: float = Field(8.0, gt=0, le=24)
    is_default: bool = False


class AssignIn(BaseModel):
    employee_code: str
    shift_id: int
    effective_from: date


class HolidayIn(BaseModel):
    holiday_date: date
    name: str = Field(min_length=1, max_length=128)


def shift_dict(s: WorkShift) -> dict:
    return {"id": s.id, "name": s.name, "start_time": s.start_time.strftime("%H:%M"), "end_time": s.end_time.strftime("%H:%M"),
            "break_minutes": s.break_minutes, "grace_minutes": s.grace_minutes, "required_hours": s.required_hours,
            "is_default": s.is_default, "is_active": s.is_active}


@router.get("/shifts")
def list_shifts(db: Session = Depends(get_db)):
    return [shift_dict(s) for s in db.scalars(select(WorkShift).where(WorkShift.is_active.is_(True)).order_by(WorkShift.id))]


@router.post("/shifts", status_code=201)
def create_shift(body: ShiftIn, db: Session = Depends(get_db)):
    if db.scalar(select(WorkShift).where(WorkShift.name == body.name)):
        raise HTTPException(409, {"error": "shift_name_exists"})
    if body.is_default:
        db.execute(update(WorkShift).values(is_default=False))
    s = WorkShift(**body.model_dump())
    db.add(s)
    db.commit()
    return shift_dict(s)


@router.put("/shifts/{shift_id}")
def update_shift(shift_id: int, body: ShiftIn, db: Session = Depends(get_db)):
    s = db.get(WorkShift, shift_id)
    if not s:
        raise HTTPException(404, {"error": "shift_not_found"})
    if body.is_default:
        db.execute(update(WorkShift).values(is_default=False))
    for k, v in body.model_dump().items():
        setattr(s, k, v)
    db.commit()
    return shift_dict(s)


@router.get("/shifts/assignments")
def assignments(db: Session = Depends(get_db)):
    q = select(EmployeeShift, Employee, WorkShift).join(Employee, Employee.id == EmployeeShift.employee_id) \
        .join(WorkShift, WorkShift.id == EmployeeShift.shift_id).order_by(EmployeeShift.id.desc()).limit(500)
    return [{"id": a.id, "employee_code": e.employee_code, "name": e.name, "shift": s.name, "shift_id": s.id,
             "effective_from": a.effective_from.isoformat(),
             "effective_to": a.effective_to.isoformat() if a.effective_to else None} for a, e, s in db.execute(q)]


@router.post("/shifts/assign", status_code=201)
def assign(body: AssignIn, db: Session = Depends(get_db)):
    emp = db.scalar(select(Employee).where(Employee.employee_code == body.employee_code))
    if not emp or not db.get(WorkShift, body.shift_id):
        raise HTTPException(404, {"error": "employee_or_shift_not_found"})
    # close the previous open assignment the day before the new one starts
    for prev in db.scalars(select(EmployeeShift).where(EmployeeShift.employee_id == emp.id, EmployeeShift.effective_to.is_(None))):
        if prev.effective_from < body.effective_from:
            prev.effective_to = date.fromordinal(body.effective_from.toordinal() - 1)
    db.add(EmployeeShift(employee_id=emp.id, shift_id=body.shift_id, effective_from=body.effective_from))
    db.commit()
    return {"assigned": True}


@router.get("/holidays")
def holidays(db: Session = Depends(get_db)):
    return [{"id": h.id, "date": h.holiday_date.isoformat(), "name": h.name}
            for h in db.scalars(select(Holiday).order_by(Holiday.holiday_date.desc()).limit(400))]


@router.post("/holidays", status_code=201)
def add_holiday(body: HolidayIn, db: Session = Depends(get_db)):
    if db.scalar(select(Holiday).where(Holiday.holiday_date == body.holiday_date)):
        raise HTTPException(409, {"error": "holiday_exists"})
    h = Holiday(holiday_date=body.holiday_date, name=body.name)
    db.add(h)
    db.commit()
    return {"id": h.id}


@router.delete("/holidays/{holiday_id}")
def delete_holiday(holiday_id: int, db: Session = Depends(get_db)):
    h = db.get(Holiday, holiday_id)
    if not h:
        raise HTTPException(404, {"error": "holiday_not_found"})
    db.delete(h)
    db.commit()
    return {"deleted": True}
