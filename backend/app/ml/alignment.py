import cv2
import numpy as np

# Standard ArcFace 112x112 five-point template
ARCFACE_TEMPLATE = np.array(
    [[38.2946, 51.6963], [73.5318, 51.5014], [56.0252, 71.7366],
     [41.5493, 92.3655], [70.7299, 92.2041]], dtype=np.float32)


def align_face(img: np.ndarray, kps: np.ndarray, size: int = 112) -> np.ndarray:
    """Similarity-transform the face so its 5 landmarks match the ArcFace template."""
    src = np.asarray(kps, dtype=np.float32).reshape(5, 2)
    dst = ARCFACE_TEMPLATE * (size / 112.0)
    m, _ = cv2.estimateAffinePartial2D(src, dst, method=cv2.LMEDS)
    if m is None:
        raise ValueError("alignment_failed")
    return cv2.warpAffine(img, m, (size, size), borderValue=0.0)
