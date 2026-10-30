import numpy as np


def l2_normalize(v: np.ndarray) -> np.ndarray:
    n = float(np.linalg.norm(v))
    return (v / max(n, 1e-12)).astype(np.float32)


def cosine(a: np.ndarray, b: np.ndarray) -> float:
    """Embeddings are L2-normalised, so dot product == cosine similarity."""
    return float(np.dot(a, b))


def embedding_to_bytes(v: np.ndarray) -> bytes:
    return np.asarray(v, dtype=np.float32).tobytes()


def embedding_from_bytes(b: bytes) -> np.ndarray:
    return np.frombuffer(b, dtype=np.float32).copy()
