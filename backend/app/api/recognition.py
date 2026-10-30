from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from sqlalchemy.orm import Session

from app.api.deps import read_upload, recognition_service
from app.core.security import require_api_key
from app.db.session import get_db
from app.utils.image import ImageDecodeError

router = APIRouter(prefix="/api/face", tags=["recognition"], dependencies=[Depends(require_api_key)])


@router.post("/recognize")
def recognize(file: UploadFile = File(...), mark_attendance: bool = True,
              db: Session = Depends(get_db), svc=Depends(recognition_service)):
    try:
        return svc.recognize(db, read_upload(file), mark_attendance)
    except ImageDecodeError as e:
        raise HTTPException(400, str(e))
