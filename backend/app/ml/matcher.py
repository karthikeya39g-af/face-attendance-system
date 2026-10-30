"""Gallery matcher: cosine similarity + threshold + margin. Not a neural network."""
import threading
from dataclasses import dataclass, field

import numpy as np

from app.utils.similarity import l2_normalize


@dataclass
class GalleryEntry:
    employee_id: int
    employee_code: str
    name: str
    matrix: np.ndarray    # (N, 512)
    centroid: np.ndarray  # (512,)


@dataclass
class MatchResult:
    recognized: bool
    reason: str | None = None
    employee_id: int | None = None
    employee_code: str | None = None
    name: str | None = None
    score: float = 0.0
    second_score: float = 0.0
    margin: float = 0.0
    stats: dict = field(default_factory=dict)


class GalleryMatcher:
    def __init__(self, threshold: float, margin: float, metric: str = "topk_mean", top_k: int = 3):
        self.threshold = threshold
        self.margin = margin
        self.metric = metric
        self.top_k = top_k
        self._entries: list[GalleryEntry] = []
        self._lock = threading.Lock()

    # ---------- gallery management ----------
    @property
    def entries(self) -> list[GalleryEntry]:
        return self._entries

    def set_gallery(self, rows: list[tuple[int, str, str, list[np.ndarray]]]) -> None:
        """rows: (employee_id, code, name, [embeddings])"""
        entries = []
        for emp_id, code, name, embs in rows:
            if not embs:
                continue
            m = np.vstack(embs).astype(np.float32)
            entries.append(GalleryEntry(emp_id, code, name, m, l2_normalize(m.mean(axis=0))))
        with self._lock:
            self._entries = entries  # atomic swap

    # ---------- matching ----------
    def employee_stats(self, entry: GalleryEntry, q: np.ndarray) -> dict:
        sims = entry.matrix @ q
        k = min(self.top_k, len(sims))
        return {
            "best": float(sims.max()),
            "topk_mean": float(np.sort(sims)[-k:].mean()),
            "median": float(np.median(sims)),
            "centroid": float(entry.centroid @ q),
            "samples": int(len(sims)),
        }

    def match(self, q: np.ndarray) -> MatchResult:
        entries = self._entries
        if not entries:
            return MatchResult(False, "gallery_empty")
        scored = []
        for e in entries:
            st = self.employee_stats(e, q)
            scored.append((st[self.metric], e, st))
        scored.sort(key=lambda t: t[0], reverse=True)
        best_score, best, st = scored[0]
        second = scored[1][0] if len(scored) > 1 else 0.0
        margin = best_score - second
        res = MatchResult(
            recognized=False, employee_id=best.employee_id, employee_code=best.employee_code,
            name=best.name, score=round(best_score, 4), second_score=round(second, 4),
            margin=round(margin, 4), stats={k: round(v, 4) if isinstance(v, float) else v for k, v in st.items()})
        if best_score < self.threshold:
            res.reason = "below_threshold"
            return res
        if len(scored) > 1 and margin < self.margin:
            res.reason = "insufficient_margin"
            return res
        res.recognized = True
        return res

    def max_similarity_to_others(self, embs: np.ndarray, exclude_code: str | None) -> tuple[float, str | None]:
        """Highest cosine between any of `embs` and any other employee's stored embeddings."""
        best, who = -1.0, None
        for e in self._entries:
            if e.employee_code == exclude_code:
                continue
            s = float((embs @ e.matrix.T).max())
            if s > best:
                best, who = s, e.employee_code
        return best, who
