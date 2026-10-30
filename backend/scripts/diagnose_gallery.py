"""Measure intra-person vs inter-person similarity to calibrate thresholds.
Run from backend/:  python -m scripts.diagnose_gallery
"""
import numpy as np

from app.db.session import SessionLocal
from app.repositories.embedding_repository import EmbeddingRepository


def main() -> None:
    with SessionLocal() as db:
        gallery = EmbeddingRepository(db).load_gallery()
    if len(gallery) == 0:
        print("Gallery is empty."); return
    mats = {code: np.vstack(embs) for _, code, _, embs in gallery}

    print("== Intra-person similarity (same person, different samples) ==")
    intra_all = []
    for code, m in mats.items():
        s = m @ m.T
        vals = s[np.triu_indices(len(m), k=1)]
        if len(vals):
            intra_all.extend(vals)
            print(f"{code:>8}: n={len(m):2d} min={vals.min():.3f} mean={vals.mean():.3f} max={vals.max():.3f}")

    print("\n== Inter-person similarity (different employees) ==")
    codes, inter_all = list(mats), []
    for i in range(len(codes)):
        for j in range(i + 1, len(codes)):
            s = mats[codes[i]] @ mats[codes[j]].T
            inter_all.extend(s.ravel())
            flag = "  <-- SUSPICIOUS, re-enroll" if s.max() > 0.6 else ""
            print(f"{codes[i]:>8} vs {codes[j]:<8} mean={s.mean():.3f} max={s.max():.3f}{flag}")

    if intra_all and inter_all:
        print(f"\nIntra mean={np.mean(intra_all):.3f}  p5={np.percentile(intra_all,5):.3f}")
        print(f"Inter mean={np.mean(inter_all):.3f}  p99={np.percentile(inter_all,99):.3f}")
        print("Pick RECOGNITION_THRESHOLD between inter p99 and intra p5 (higher = safer).")


if __name__ == "__main__":
    main()
