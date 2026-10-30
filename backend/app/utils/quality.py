import cv2
import numpy as np

from app.core.config import Settings


def blur_score(img: np.ndarray, bbox: np.ndarray) -> float:
    """Laplacian variance of the face crop, normalised to 160x160 so it does not
    depend on how far the person stands from the camera."""
    x1, y1, x2, y2 = [int(v) for v in bbox]
    h, w = img.shape[:2]
    x1, y1, x2, y2 = max(0, x1), max(0, y1), min(w, x2), min(h, y2)
    crop = img[y1:y2, x1:x2]
    if crop.size == 0:
        return 0.0
    gray = cv2.cvtColor(cv2.resize(crop, (160, 160)), cv2.COLOR_BGR2GRAY)
    return float(cv2.Laplacian(gray, cv2.CV_64F).var())


def check_quality(img: np.ndarray, bbox: np.ndarray, s: Settings) -> tuple[bool, str | None, dict]:
    h, w = img.shape[:2]
    fw = float(bbox[2] - bbox[0])
    fh = float(bbox[3] - bbox[1])
    area_ratio = (fw * fh) / float(w * h)
    blur = blur_score(img, bbox)
    metrics = {
        "face_width": round(fw, 1),
        "face_height": round(fh, 1),
        "area_ratio": round(area_ratio, 4),
        "blur_score": round(blur, 2),
    }
    if fw < s.MIN_FACE_WIDTH or fh < s.MIN_FACE_HEIGHT:
        return False, "face_too_small", metrics
    if area_ratio < s.MIN_FACE_AREA_RATIO:
        return False, "face_area_too_small", metrics
    if blur < s.MIN_BLUR_SCORE:
        return False, "image_too_blurry", metrics
    return True, None, metrics
