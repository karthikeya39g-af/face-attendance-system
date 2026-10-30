import time

from sqlalchemy.orm import Session

from app.core.config import Settings
from app.ml.matcher import GalleryMatcher
from app.ml.model_manager import ModelManager
from app.repositories.attendance_repository import EventRepository
from app.repositories.employee_repository import EmployeeRepository
from app.services.attendance_service import AttendanceService
from app.utils.image import decode_image


class RecognitionService:
    def __init__(self, models: ModelManager, matcher: GalleryMatcher,
                 attendance: AttendanceService, settings: Settings):
        self.models, self.matcher, self.attendance, self.s = models, matcher, attendance, settings
        self._last_event: dict[str, float] = {}

    def _throttled(self, key: str) -> bool:
        now = time.monotonic()
        if now - self._last_event.get(key, 0) < self.s.EVENT_THROTTLE_SECONDS:
            return True
        self._last_event[key] = now
        return False

    def recognize(self, db: Session, data: bytes, mark_attendance: bool = True) -> dict:
        img = decode_image(data, self.s.MAX_IMAGE_SIDE)
        a = self.models.pipeline.analyze(img)
        resp: dict = {
            "success": True,
            "face_detected": a.detection is not None,
            "face_score": round(a.detection.score, 4) if a.detection else None,
            "quality": a.quality or None,
            "liveness": ({"label": a.liveness["label"], "score": a.liveness["score"]} if a.liveness else None),
            "recognized": False,
            "employee": None, "score": None, "second_score": None, "margin": None,
            "reason": a.reason, "attendance": None,
            "bbox": [round(float(v), 1) for v in a.detection.bbox] if a.detection else None,
            "image_size": [int(img.shape[1]), int(img.shape[0])],
        }
        events = EventRepository(db)

        if not a.ok:
            if a.reason == "spoof_detected" and not self._throttled("spoof"):
                events.add("LIVENESS_REJECTED", details={"liveness": a.liveness})
                db.commit()
            elif a.reason in ("face_too_small", "face_area_too_small", "image_too_blurry") and not self._throttled("lowq"):
                events.add("LOW_QUALITY", details={"reason": a.reason, "quality": a.quality})
                db.commit()
            return resp

        m = self.matcher.match(a.embedding)
        resp.update(score=m.score, second_score=m.second_score, margin=m.margin, reason=m.reason,
                    candidate=m.employee_code, stats=m.stats)
        if not m.recognized:
            if not self._throttled("unknown"):
                events.add("UNKNOWN_FACE", similarity=m.score,
                           details={"reason": m.reason, "candidate": m.employee_code, "margin": m.margin})
                db.commit()
            return resp

        emp = EmployeeRepository(db).by_code(m.employee_code)
        if emp is None or not emp.is_active:
            resp["recognized"], resp["reason"] = False, "employee_inactive"
            return resp
        resp["recognized"] = True
        resp["employee"] = {"employee_code": emp.employee_code, "name": emp.name, "office": emp.office.code}
        if mark_attendance:
            resp["attendance"] = self.attendance.mark(db, emp, m.score)
            if not self._throttled(f"rec:{emp.id}"):
                events.add("RECOGNITION", emp.id, emp.office_id, m.score)
            db.commit()
        return resp
