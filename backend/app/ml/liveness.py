"""MiniFASNetV2 anti-spoofing (Silent-Face-Anti-Spoofing, crop scale 2.7, 80x80 BGR)."""
import cv2
import numpy as np
import onnxruntime as ort


def _softmax(x: np.ndarray) -> np.ndarray:
    e = np.exp(x - np.max(x))
    return e / e.sum()


class MiniFASNetLiveness:
    def __init__(self, path, real_index: int = 1, threshold: float = 0.8, crop_scale: float = 2.7):
        self.session = ort.InferenceSession(str(path), providers=["CPUExecutionProvider"])
        inp = self.session.get_inputs()[0]
        self.input_name = inp.name
        self.input_shape = list(inp.shape)
        self.size = (
            int(self.input_shape[3]) if len(self.input_shape) == 4 and isinstance(self.input_shape[3], int) else 80
        )
        self.real_index = real_index
        self.threshold = threshold
        self.crop_scale = crop_scale

    def _crop(self, img: np.ndarray, bbox: np.ndarray) -> np.ndarray:
        x1, y1, x2, y2 = [float(v) for v in bbox]
        w, h = x2 - x1, y2 - y1
        sh, sw = img.shape[:2]
        scale = min((sh - 1) / h, (sw - 1) / w, self.crop_scale)
        nw, nh = w * scale, h * scale
        cx, cy = x1 + w / 2, y1 + h / 2
        lx, ly, rx, ry = cx - nw / 2, cy - nh / 2, cx + nw / 2, cy + nh / 2
        if lx < 0: rx -= lx; lx = 0
        if ly < 0: ry -= ly; ly = 0
        if rx > sw - 1: lx -= rx - sw + 1; rx = sw - 1
        if ry > sh - 1: ly -= ry - sh + 1; ry = sh - 1
        crop = img[int(ly): int(ry) + 1, int(lx): int(rx) + 1]
        return cv2.resize(crop, (self.size, self.size))

    def predict(self, img: np.ndarray, bbox: np.ndarray) -> dict:
        crop = self._crop(img, bbox)
        # Original model: BGR, float32, 0..255 (NO /255), CHW
        blob = crop.astype(np.float32).transpose(2, 0, 1)[None]
        raw = self.session.run(None, {self.input_name: blob})[0][0]
        probs = raw if abs(float(raw.sum()) - 1.0) < 1e-3 and raw.min() >= 0 else _softmax(raw)
        real = float(probs[self.real_index])
        is_live = int(np.argmax(probs)) == self.real_index and real >= self.threshold
        return {
            "is_live": bool(is_live),
            "label": "Real" if is_live else "Fake",
            "score": round(real, 4),
            "probs": [round(float(p), 4) for p in probs],
        }
