from datetime import datetime, timedelta

from sqlalchemy import func, select
from sqlalchemy.orm import Session, joinedload

from app.core.config import Settings
from app.db.models import AttendanceEvent, Employee, Office
from app.services.attendance_calc import AttendanceCalcService
from app.services.payroll_service import PayrollService
from app.utils.time import now_local


class DashboardService:
    def __init__(self, settings: Settings):
        self.s = settings

    def summary(self, db: Session, office_code: str | None = None, trend_days: int = 14) -> dict:
        now = now_local(self.s.TIMEZONE)
        today = now.date()
        q = select(Employee).options(joinedload(Employee.office))
        all_emps = list(db.scalars(q))
        if office_code:
            all_emps = [e for e in all_emps if e.office.code == office_code]
        active = [e for e in all_emps if e.is_active]
        calc = AttendanceCalcService(db, self.s)
        ids = [e.id for e in active]
        rng = calc.compute_range(ids, today - timedelta(days=trend_days - 1), today, now)
        t = {i: rng[i][today] for i in ids}

        cnt = lambda f: sum(1 for r in t.values() if f(r))  # noqa: E731
        worked = [r.worked_minutes for r in t.values() if r.checked_in]
        today_stats = {
            "present": cnt(lambda r: r.checked_in), "absent": cnt(lambda r: r.status == "ABSENT"),
            "not_arrived": cnt(lambda r: r.status == "NOT_ARRIVED"), "half_day": cnt(lambda r: r.status == "HALF_DAY"),
            "on_leave": cnt(lambda r: r.status == "ON_LEAVE"), "late": cnt(lambda r: r.late_minutes > 0),
            "early_checkout": cnt(lambda r: r.early_minutes > 0), "currently_working": cnt(lambda r: r.currently_working),
            "holiday_or_weekoff": cnt(lambda r: r.status in ("HOLIDAY", "WEEK_OFF")),
        }
        hours = {"total_hours": round(sum(worked) / 60, 2),
                 "average_hours": round(sum(worked) / 60 / len(worked), 2) if worked else 0.0,
                 "overtime_hours": round(sum(r.overtime_minutes for r in t.values()) / 60, 2)}

        trend = []
        for k in range(trend_days):
            d = today - timedelta(days=trend_days - 1 - k)
            rs = [rng[i][d] for i in ids]
            trend.append({"date": d.isoformat(),
                          "present": sum(1 for r in rs if r.checked_in),
                          "absent": sum(1 for r in rs if r.status == "ABSENT"),
                          "on_leave": sum(1 for r in rs if r.status == "ON_LEAVE"),
                          "late": sum(1 for r in rs if r.late_minutes > 0),
                          "hours": round(sum(r.worked_minutes for r in rs) / 60, 1),
                          "overtime": round(sum(r.overtime_minutes for r in rs) / 60, 1)})

        offices = []
        for o in db.scalars(select(Office).order_by(Office.id)):
            es = [e for e in active if e.office_id == o.id]
            offices.append({"office": o.code, "name": o.name, "employees": len(es),
                            "present": sum(1 for e in es if t[e.id].checked_in)})

        start = datetime.combine(today, datetime.min.time(), tzinfo=now.tzinfo)
        ev = dict(db.execute(select(AttendanceEvent.event_type, func.count()).where(
            AttendanceEvent.created_at >= start).group_by(AttendanceEvent.event_type)).all())
        avg = db.scalar(select(func.avg(AttendanceEvent.similarity)).where(
            AttendanceEvent.created_at >= start, AttendanceEvent.event_type == "RECOGNITION"))
        ai = {"recognized": ev.get("RECOGNITION", 0), "unknown": ev.get("UNKNOWN_FACE", 0),
              "liveness_rejected": ev.get("LIVENESS_REJECTED", 0), "low_quality": ev.get("LOW_QUALITY", 0),
              "average_confidence": round(float(avg), 3) if avg is not None else None}

        month_start = today.replace(day=1)
        employees = {"total": len(all_emps), "active": len(active), "inactive": len(all_emps) - len(active),
                     "new_this_month": sum(1 for e in all_emps if e.created_at and e.created_at.date() >= month_start)}
        return {"date": today.isoformat(), "employees": employees, "today": today_stats, "hours": hours,
                "trend": trend, "offices": offices, "ai": ai, "payroll": PayrollService(self.s).dashboard(db)}
