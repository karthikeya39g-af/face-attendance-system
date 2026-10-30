from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.security import require_api_key
from app.db.models import Employee, Office
from app.db.session import get_db

router = APIRouter(prefix="/api/offices", tags=["offices"], dependencies=[Depends(require_api_key)])


class OfficeIn(BaseModel):
    code: str = Field(min_length=1, max_length=32, pattern=r"^[A-Za-z0-9_-]+$")
    name: str = Field(min_length=1, max_length=128)


@router.get("")
def list_offices(db: Session = Depends(get_db)):
    counts = dict(db.execute(select(Employee.office_id, func.count()).where(Employee.is_active.is_(True))
                             .group_by(Employee.office_id)).all())
    return [{"id": o.id, "code": o.code, "name": o.name, "employees": counts.get(o.id, 0)}
            for o in db.scalars(select(Office).order_by(Office.id))]


@router.post("", status_code=201)
def create_office(body: OfficeIn, db: Session = Depends(get_db)):
    code = body.code.upper()
    if db.scalar(select(Office).where(Office.code == code)):
        raise HTTPException(409, {"error": "office_code_exists"})
    o = Office(code=code, name=body.name)
    db.add(o)
    db.commit()
    return {"id": o.id, "code": o.code, "name": o.name}


@router.patch("/{code}")
def rename_office(code: str, body: OfficeIn, db: Session = Depends(get_db)):
    o = db.scalar(select(Office).where(Office.code == code.upper()))
    if not o:
        raise HTTPException(404, {"error": "office_not_found"})
    o.name = body.name
    db.commit()
    return {"id": o.id, "code": o.code, "name": o.name}
