from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.api.deps import actor
from app.core.config import Settings, get_settings
from app.core.security import require_api_key
from app.db.models import (Employee, PayrollAdjustment, PayrollAudit, PayrollPeriod, PayrollRecord)
from app.db.session import get_db
from app.services.payroll_service import PayrollError, PayrollService

router = APIRouter(prefix="/api/payroll", tags=["payroll"], dependencies=[Depends(require_api_key)])


def svc(s: Settings = Depends(get_settings)) -> PayrollService:
    return PayrollService(s)


def run(fn, *a, **k):
    try:
        return fn(*a, **k)
    except PayrollError as e:
        raise HTTPException(e.status, {"error": e.code, "message": e.message, **e.details})


class PeriodIn(BaseModel):
    year: int
    month: int = Field(ge=1, le=12)


class AdjustmentIn(BaseModel):
    payroll_record_id: int
    type: str
    description: str = Field(min_length=1, max_length=255)
    amount: Decimal


def period_dict(p: PayrollPeriod, totals: dict | None = None) -> dict:
    d = {"id": p.id, "year": p.period_year, "month": p.period_month, "start_date": p.start_date.isoformat(),
         "end_date": p.end_date.isoformat(), "status": p.status, "calculated_by": p.calculated_by,
         "approved_by": p.approved_by, "processed_by": p.processed_by,
         "calculated_at": p.calculated_at.isoformat() if p.calculated_at else None,
         "approved_at": p.approved_at.isoformat() if p.approved_at else None,
         "processed_at": p.processed_at.isoformat() if p.processed_at else None,
         "paid_at": p.paid_at.isoformat() if p.paid_at else None}
    if totals is not None:
        d["totals"] = totals
    return d


@router.get("/dashboard")
def dashboard(db: Session = Depends(get_db), s: PayrollService = Depends(svc)):
    return s.dashboard(db)


@router.get("/periods")
def periods(db: Session = Depends(get_db), s: PayrollService = Depends(svc)):
    ps = db.scalars(select(PayrollPeriod).order_by(PayrollPeriod.period_year.desc(), PayrollPeriod.period_month.desc()))
    return [period_dict(p, s.totals(db, p.id)) for p in ps]


@router.post("/periods", status_code=201)
def create_period(body: PeriodIn, db: Session = Depends(get_db), s: PayrollService = Depends(svc), who: str = Depends(actor)):
    return period_dict(run(s.create_period, db, body.year, body.month, who))


@router.get("/periods/{period_id}")
def get_period(period_id: int, db: Session = Depends(get_db), s: PayrollService = Depends(svc)):
    p = run(s.get_period, db, period_id)
    recs = db.scalars(select(PayrollRecord).options(joinedload(PayrollRecord.employee))
                      .where(PayrollRecord.payroll_period_id == p.id).order_by(PayrollRecord.employee_id)).unique()
    audit = db.scalars(select(PayrollAudit).where(PayrollAudit.payroll_period_id == p.id)
                       .order_by(PayrollAudit.id.desc()).limit(50))
    return {**period_dict(p, s.totals(db, p.id)), "records": [s.record_dict(r) for r in recs],
            "audit": [{"action": a.action, "actor": a.actor, "at": a.created_at.isoformat() if a.created_at else None,
                       "new": a.new_value} for a in audit]}


@router.post("/periods/{period_id}/calculate")
def calculate(period_id: int, db: Session = Depends(get_db), s: PayrollService = Depends(svc), who: str = Depends(actor)):
    return run(s.calculate, db, period_id, who)


@router.post("/periods/{period_id}/approve")
def approve(period_id: int, db: Session = Depends(get_db), s: PayrollService = Depends(svc), who: str = Depends(actor)):
    return period_dict(run(s.transition, db, period_id, "APPROVED", who))


@router.post("/periods/{period_id}/process")
def process(period_id: int, db: Session = Depends(get_db), s: PayrollService = Depends(svc), who: str = Depends(actor)):
    return period_dict(run(s.transition, db, period_id, "PROCESSED", who))


@router.post("/periods/{period_id}/pay")
def pay(period_id: int, db: Session = Depends(get_db), s: PayrollService = Depends(svc), who: str = Depends(actor)):
    return period_dict(run(s.transition, db, period_id, "PAID", who))


@router.get("/records")
def records(period_id: int | None = None, db: Session = Depends(get_db), s: PayrollService = Depends(svc)):
    q = select(PayrollRecord).options(joinedload(PayrollRecord.employee)).order_by(PayrollRecord.id.desc()).limit(1000)
    if period_id:
        q = q.where(PayrollRecord.payroll_period_id == period_id)
    return [s.record_dict(r) for r in db.scalars(q).unique()]


@router.get("/records/{record_id}")
def record(record_id: int, db: Session = Depends(get_db), s: PayrollService = Depends(svc)):
    r = db.get(PayrollRecord, record_id)
    if not r:
        raise HTTPException(404, {"error": "record_not_found"})
    adjs = db.scalars(select(PayrollAdjustment).where(PayrollAdjustment.payroll_record_id == r.id))
    return {**s.record_dict(r, with_breakdown=True),
            "adjustments": [{"id": a.id, "type": a.type, "description": a.description, "amount": float(a.amount),
                             "by": a.created_by} for a in adjs]}


@router.get("/employee/{employee_code}")
def employee_latest(employee_code: str, db: Session = Depends(get_db), s: PayrollService = Depends(svc)):
    r = _emp_records(db, employee_code, 1)
    return s.record_dict(r[0], with_breakdown=True) if r else None


@router.get("/employee/{employee_code}/history")
def employee_history(employee_code: str, db: Session = Depends(get_db), s: PayrollService = Depends(svc)):
    return [s.record_dict(r) for r in _emp_records(db, employee_code, 36)]


def _emp_records(db, code, limit):
    emp = db.scalar(select(Employee).where(Employee.employee_code == code))
    if not emp:
        raise HTTPException(404, {"error": "employee_not_found"})
    return list(db.scalars(select(PayrollRecord).options(joinedload(PayrollRecord.employee))
                           .join(PayrollPeriod, PayrollPeriod.id == PayrollRecord.payroll_period_id)
                           .where(PayrollRecord.employee_id == emp.id)
                           .order_by(PayrollPeriod.period_year.desc(), PayrollPeriod.period_month.desc()).limit(limit)).unique())


@router.post("/adjustments", status_code=201)
def add_adjustment(body: AdjustmentIn, db: Session = Depends(get_db), s: PayrollService = Depends(svc), who: str = Depends(actor)):
    a = run(s.add_adjustment, db, body.payroll_record_id, body.type.upper(), body.description, body.amount, who)
    return {"id": a.id, "type": a.type, "amount": float(a.amount), "note": "Run calculate again to apply."}
