from sqlalchemy.orm import Session

from app.repositories.employee_repository import EmployeeRepository, OfficeRepository


class EmployeeError(Exception):
    def __init__(self, code: str, status: int = 400):
        self.code, self.status = code, status


class EmployeeService:
    def list(self, db: Session) -> list[dict]:
        repo = EmployeeRepository(db)
        counts = repo.embedding_counts()
        return [self.to_dict(e, counts.get(e.id, 0)) for e in repo.list()]

    def get(self, db: Session, code: str) -> dict:
        repo = EmployeeRepository(db)
        e = repo.by_code(code)
        if not e:
            raise EmployeeError("employee_not_found", 404)
        return self.to_dict(e, repo.embedding_counts().get(e.id, 0))

    def create(self, db: Session, code: str, name: str, office_code: str,
               department: str | None = None, designation: str | None = None,
               email: str | None = None, phone: str | None = None) -> dict:
        repo = EmployeeRepository(db)
        if repo.by_code(code):
            raise EmployeeError("employee_code_exists", 409)
        office = OfficeRepository(db).by_code(office_code)
        if not office:
            raise EmployeeError("unknown_office", 422)
        e = repo.create(code, name, office.id, department=department, designation=designation, email=email, phone=phone)
        db.commit()
        return self.to_dict(repo.by_code(code), 0)

    def update(self, db: Session, code: str, name: str | None = None, office_code: str | None = None,
               department: str | None = None, designation: str | None = None,
               email: str | None = None, phone: str | None = None) -> dict:
        repo = EmployeeRepository(db)
        e = repo.by_code(code)
        if not e:
            raise EmployeeError("employee_not_found", 404)
        if name is not None:
            e.name = name
        if department is not None:
            e.department = department
        if designation is not None:
            e.designation = designation
        if email is not None:
            e.email = email
        if phone is not None:
            e.phone = phone
        if office_code:
            office = OfficeRepository(db).by_code(office_code)
            if not office:
                raise EmployeeError("unknown_office", 422)
            e.office_id = office.id
        db.commit()
        return self.to_dict(repo.by_code(code), repo.embedding_counts().get(e.id, 0))

    def deactivate(self, db: Session, code: str) -> None:
        """Soft delete: keeps attendance history, removes the person from the live gallery."""
        e = EmployeeRepository(db).by_code(code)
        if not e:
            raise EmployeeError("employee_not_found", 404)
        e.is_active = False
        db.commit()

    @staticmethod
    def to_dict(e, n_emb: int) -> dict:
        return {"employee_code": e.employee_code, "name": e.name, "office": e.office.code,
                "department": e.department, "designation": e.designation,
                "email": e.email, "phone": e.phone,
                "is_active": e.is_active, "embedding_count": n_emb}
