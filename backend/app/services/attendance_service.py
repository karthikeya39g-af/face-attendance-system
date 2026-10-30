from datetime import timedelta

from sqlalchemy.orm import Session

from app.core.config import Settings
from app.db.models import Employee
from app.repositories.attendance_repository import AttendanceRepository, EventRepository
from app.utils.time import as_aware, now_local


class AttendanceService:
    def __init__(self, settings: Settings):
        self.s = settings

    def mark(self, db: Session, emp: Employee, similarity: float | None, force: str | None = None) -> dict:
        """Check-in on first sighting of the day, check-out after the cooldown.
        force: 'CHECK_IN' | 'CHECK_OUT' for manual calls. Caller commits."""
        repo, events = AttendanceRepository(db), EventRepository(db)
        now = now_local(self.s.TIMEZONE)
        today = now.date()
        rec = repo.get_for_day(emp.id, today)

        if force == "CHECK_OUT" and (rec is None or rec.check_in_time is None):
            return {"action": "NO_CHECK_IN", "message": "Employee has not checked in today"}

        if rec is None:
            rec = repo.create(employee_id=emp.id, office_id=emp.office_id, attendance_date=today,
                              check_in_time=now, check_in_similarity=similarity, status="CHECKED_IN")
            events.add("CHECK_IN", emp.id, emp.office_id, similarity)
            return {"action": "CHECK_IN", "time": now.isoformat()}

        if force == "CHECK_IN":
            return {"action": "ALREADY_CHECKED_IN", "time": rec.check_in_time.isoformat()}

        if rec.check_out_time is None:
            elapsed = now - as_aware(rec.check_in_time, self.s.TIMEZONE)
            wait = timedelta(minutes=self.s.MIN_MINUTES_BEFORE_CHECKOUT)
            if force != "CHECK_OUT" and elapsed < wait:
                left = int((wait - elapsed).total_seconds() // 60) + 1
                return {"action": "ALREADY_CHECKED_IN", "time": rec.check_in_time.isoformat(),
                        "message": f"Check-out available in ~{left} min"}
            rec.check_out_time, rec.check_out_similarity, rec.status = now, similarity, "CHECKED_OUT"
            events.add("CHECK_OUT", emp.id, emp.office_id, similarity)
            return {"action": "CHECK_OUT", "time": now.isoformat()}

        return {"action": "ALREADY_CHECKED_OUT", "time": rec.check_out_time.isoformat()}
