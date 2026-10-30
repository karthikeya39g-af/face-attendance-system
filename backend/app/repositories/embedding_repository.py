import numpy as np
from sqlalchemy import delete, select
from sqlalchemy.orm import Session

from app.db.models import Employee, FaceEmbedding
from app.utils.similarity import embedding_from_bytes, embedding_to_bytes


class EmbeddingRepository:
    def __init__(self, db: Session):
        self.db = db

    def replace_for_employee(self, employee_id: int, items: list[dict], model_name: str = "w600k_mbf") -> None:
        """Delete old + insert new. Caller owns the transaction (commit/rollback)."""
        self.db.execute(delete(FaceEmbedding).where(FaceEmbedding.employee_id == employee_id))
        for it in items:
            self.db.add(FaceEmbedding(
                employee_id=employee_id, embedding=embedding_to_bytes(it["embedding"]),
                model_name=model_name, blur_score=it.get("blur_score"),
                liveness_score=it.get("liveness_score")))

    def load_gallery(self) -> list[tuple[int, str, str, list[np.ndarray]]]:
        rows = self.db.execute(
            select(Employee.id, Employee.employee_code, Employee.name, FaceEmbedding.embedding)
            .join(FaceEmbedding, FaceEmbedding.employee_id == Employee.id)
            .where(Employee.is_active.is_(True))
            .order_by(Employee.id, FaceEmbedding.id)).all()
        grouped: dict[int, tuple[str, str, list[np.ndarray]]] = {}
        for emp_id, code, name, blob in rows:
            grouped.setdefault(emp_id, (code, name, []))[2].append(embedding_from_bytes(blob))
        return [(i, c, n, e) for i, (c, n, e) in grouped.items()]
