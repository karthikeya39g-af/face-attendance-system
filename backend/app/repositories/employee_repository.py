from sqlalchemy import func, select
from sqlalchemy.orm import Session, joinedload

from app.db.models import Employee, FaceEmbedding, Office


class OfficeRepository:
    def __init__(self, db: Session):
        self.db = db

    def list(self) -> list[Office]:
        return list(self.db.scalars(select(Office).order_by(Office.id)))

    def by_code(self, code: str) -> Office | None:
        return self.db.scalar(select(Office).where(Office.code == code))


class EmployeeRepository:
    def __init__(self, db: Session):
        self.db = db

    def list(self, only_active: bool = True) -> list[Employee]:
        q = select(Employee).options(joinedload(Employee.office)).order_by(Employee.employee_code)
        if only_active:
            q = q.where(Employee.is_active.is_(True))
        return list(self.db.scalars(q))

    def by_code(self, code: str) -> Employee | None:
        return self.db.scalar(
            select(Employee).options(joinedload(Employee.office)).where(Employee.employee_code == code))

    def create(self, code: str, name: str, office_id: int,
               department: str | None = None, designation: str | None = None,
               email: str | None = None, phone: str | None = None) -> Employee:
        e = Employee(employee_code=code, name=name, office_id=office_id,
                     department=department, designation=designation, email=email, phone=phone)
        self.db.add(e)
        self.db.flush()
        return e

    def embedding_counts(self) -> dict[int, int]:
        rows = self.db.execute(
            select(FaceEmbedding.employee_id, func.count()).group_by(FaceEmbedding.employee_id))
        return {r[0]: r[1] for r in rows}
