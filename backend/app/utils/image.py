import cv2
import numpy as np


class ImageDecodeError(ValueError):
    pass


def decode_image(data: bytes, max_side: int = 1280) -> np.ndarray:
    """JPEG/PNG bytes -> BGR ndarray (downscaled if very large)."""
    if not data:
        raise ImageDecodeError("empty_image")
    arr = np.frombuffer(data, dtype=np.uint8)
    img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
    if img is None:
        raise ImageDecodeError("invalid_image")
    h, w = img.shape[:2]
    m = max(h, w)
    if m > max_side:
        s = max_side / m
        img = cv2.resize(img, (int(w * s), int(h * s)), interpolation=cv2.INTER_AREA)
    return img
