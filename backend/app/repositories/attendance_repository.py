from datetime import date

from sqlalchemy import func, select
from sqlalchemy.orm import Session, joinedload

from app.db.models import Attendance, AttendanceEvent


class AttendanceRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_for_day(self, employee_id: int, day: date) -> Attendance | None:
        return self.db.scalar(select(Attendance).where(
            Attendance.employee_id == employee_id, Attendance.attendance_date == day))

    def create(self, **kw) -> Attendance:
        a = Attendance(**kw)
        self.db.add(a)
        self.db.flush()
        return a

    def list_day(self, day: date) -> list[Attendance]:
        return list(self.db.scalars(
            select(Attendance).options(joinedload(Attendance.employee))
            .where(Attendance.attendance_date == day).order_by(Attendance.check_in_time)))

    def history(self, start: date | None, end: date | None, employee_id: int | None, limit: int = 500):
        q = select(Attendance).options(joinedload(Attendance.employee)).order_by(
            Attendance.attendance_date.desc(), Attendance.id.desc()).limit(limit)
        if start:
            q = q.where(Attendance.attendance_date >= start)
        if end:
            q = q.where(Attendance.attendance_date <= end)
        if employee_id:
            q = q.where(Attendance.employee_id == employee_id)
        return list(self.db.scalars(q))

    def count_day(self, day: date, checked_out: bool | None = None) -> int:
        q = select(func.count()).select_from(Attendance).where(Attendance.attendance_date == day)
        if checked_out is True:
            q = q.where(Attendance.check_out_time.is_not(None))
        return int(self.db.scalar(q) or 0)


class EventRepository:
    def __init__(self, db: Session):
        self.db = db

    def add(self, event_type: str, employee_id: int | None = None, office_id: int | None = None,
            similarity: float | None = None, details: dict | None = None) -> None:
        self.db.add(AttendanceEvent(event_type=event_type, employee_id=employee_id,
                                    office_id=office_id, similarity=similarity, details=details))

    def recent(self, limit: int = 200, event_type: str | None = None) -> list[AttendanceEvent]:
        q = select(AttendanceEvent).order_by(AttendanceEvent.id.desc()).limit(limit)
        if event_type:
            q = q.where(AttendanceEvent.event_type == event_type)
        return list(self.db.scalars(q))
