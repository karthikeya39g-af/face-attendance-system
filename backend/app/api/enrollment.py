from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlalchemy.orm import Session

from app.api.deps import enrollment_service, read_upload
from app.core.security import require_api_key
from app.db.session import get_db
from app.schemas.enrollment import EnrollmentComplete, EnrollmentStart
from app.services.enrollment_service import EnrollmentError
from app.utils.image import ImageDecodeError

router = APIRouter(prefix="/api/enrollment", tags=["enrollment"], dependencies=[Depends(require_api_key)])


def _err(e: EnrollmentError):
    return HTTPException(e.status, {"error": e.code, **e.detail})


@router.post("/start")
def start(body: EnrollmentStart, db: Session = Depends(get_db), svc=Depends(enrollment_service)):
    try:
        return svc.start(db, body.employee_code, body.name, body.office_code)
    except EnrollmentError as e:
        raise _err(e)


@router.post("/sample")
def sample(session_id: str = Form(...), file: UploadFile = File(...), svc=Depends(enrollment_service)):
    try:
        return svc.add_sample(session_id, read_upload(file))
    except EnrollmentError as e:
        raise _err(e)
    except ImageDecodeError as e:
        raise HTTPException(400, str(e))


@router.post("/complete")
def complete(body: EnrollmentComplete, db: Session = Depends(get_db), svc=Depends(enrollment_service)):
    try:
        return svc.complete(db, body.session_id)
    except EnrollmentError as e:
        raise _err(e)


@router.post("/cancel/{session_id}")
@router.delete("/cancel/{session_id}")
def cancel(session_id: str, svc=Depends(enrollment_service)):
    return {"cancelled": svc.cancel(session_id)}
