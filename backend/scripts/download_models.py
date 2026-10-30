"""Download the 3 ONNX models into models/. Run from backend/:  python -m scripts.download_models"""
import shutil
import tempfile
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "models"
BUFFALO_S = "https://github.com/deepinsight/insightface/releases/download/v0.7/buffalo_s.zip"
MINIFAS = "https://github.com/yakhyo/face-anti-spoofing/releases/download/weights/MiniFASNetV2.onnx"

TARGETS = {
    "detection/scrfd_500m_kps.onnx": 2_000_000,   # min plausible size in bytes
    "recognition/w600k_mbf.onnx": 10_000_000,
    "liveness/MiniFASNetV2.onnx": 1_000_000,
}


def fetch(url: str, dest: Path) -> None:
    print(f"  downloading {url}")
    with urllib.request.urlopen(url, timeout=180) as r, open(dest, "wb") as f:
        shutil.copyfileobj(r, f)


def main() -> None:
    missing = [t for t in TARGETS if not (ROOT / t).exists()]
    if not missing:
        print("All models already present.")
    else:
        with tempfile.TemporaryDirectory() as tmp:
            tmp = Path(tmp)
            if any(m.startswith(("detection", "recognition")) for m in missing):
                print("Fetching InsightFace buffalo_s pack (~120 MB; only 2 files are used)...")
                fetch(BUFFALO_S, tmp / "buffalo_s.zip")
                with zipfile.ZipFile(tmp / "buffalo_s.zip") as z:
                    z.extract("det_500m.onnx", tmp)       # = SCRFD 500M with keypoints
                    z.extract("w600k_mbf.onnx", tmp)
                for src, dst in (("det_500m.onnx", "detection/scrfd_500m_kps.onnx"),
                                 ("w600k_mbf.onnx", "recognition/w600k_mbf.onnx")):
                    (ROOT / dst).parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy(tmp / src, ROOT / dst)
            if "liveness/MiniFASNetV2.onnx" in missing:
                print("Fetching MiniFASNetV2...")
                (ROOT / "liveness").mkdir(parents=True, exist_ok=True)
                fetch(MINIFAS, ROOT / "liveness/MiniFASNetV2.onnx")

    ok = True
    for rel, min_size in TARGETS.items():
        p = ROOT / rel
        good = p.exists() and p.stat().st_size >= min_size
        ok &= good
        print(f"[{'OK' if good else 'BAD'}] {rel}  {p.stat().st_size / 1e6:.1f} MB" if p.exists() else f"[MISSING] {rel}")
    if not ok:
        raise SystemExit("Some models are missing or too small.")
    print("\nModels ready.")


if __name__ == "__main__":
    main()
