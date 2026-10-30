from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.core.security import require_api_key
from app.db.session import get_db
from app.services.policy import Policy, get_policy, save_policy

router = APIRouter(prefix="/api", tags=["settings"], dependencies=[Depends(require_api_key)])


@router.get("/settings/policy")
def read_policy(db: Session = Depends(get_db)):
    return get_policy(db).model_dump()


@router.put("/settings/policy")
def write_policy(body: Policy, db: Session = Depends(get_db)):
    return save_policy(db, body).model_dump()


@router.get("/system/config")
def system_config(request: Request, s: Settings = Depends(get_settings)):
    """Read-only view of recognition/quality thresholds (set in .env)."""
    keys = ["ENROLLMENT_TARGET", "RECOGNITION_THRESHOLD", "RECOGNITION_MARGIN", "RECOGNITION_SCORE_METRIC",
            "RECOGNITION_TOP_K", "LIVENESS_THRESHOLD", "LIVENESS_REAL_INDEX", "MIN_FACE_WIDTH", "MIN_FACE_HEIGHT",
            "MIN_FACE_AREA_RATIO", "MIN_BLUR_SCORE", "DUPLICATE_SIMILARITY", "MIN_CENTROID_SIMILARITY",
            "ENROLL_MAX_CROSS_SIMILARITY", "MIN_MINUTES_BEFORE_CHECKOUT", "TIMEZONE"]
    return {k: getattr(s, k) for k in keys} | {"gallery_employees": len(request.app.state.matcher.entries)}
