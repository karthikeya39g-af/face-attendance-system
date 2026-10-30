"""w600k_mbf (ArcFace MobileFaceNet) -> 512-D L2-normalised embedding."""
import cv2
import numpy as np
import onnxruntime as ort

from app.utils.similarity import l2_normalize


class FaceRecognizer:
    def __init__(self, path):
        self.session = ort.InferenceSession(str(path), providers=["CPUExecutionProvider"])
        self.input_name = self.session.get_inputs()[0].name
        self.dim = None

    def embed(self, aligned_bgr_112: np.ndarray) -> np.ndarray:
        blob = cv2.dnn.blobFromImage(
            aligned_bgr_112, 1.0 / 127.5, (112, 112), (127.5, 127.5, 127.5), swapRB=True)
        out = self.session.run(None, {self.input_name: blob})[0][0]
        return l2_normalize(out)
