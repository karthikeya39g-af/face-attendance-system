import { forwardRef, useEffect, useImperativeHandle, useRef, useState } from "react";
import { useCameraService } from "./CameraProvider";

export type FaceOverlay = { bbox: number[]; image: number[]; label?: string; tone?: "good" | "warn" | "bad" } | null;
export type CameraHandle = { capture: () => Promise<Blob | null>; isReady: () => boolean };

const TONE = { good: "border-emerald-400 bg-emerald-500", warn: "border-amber-400 bg-amber-500", bad: "border-red-400 bg-red-500" };

/** Shows the shared camera stream in its OWN <video>. Always attaches the existing stream on mount. */
const CameraView = forwardRef<CameraHandle, { overlay?: FaceOverlay; className?: string }>(function CameraView({ overlay, className }, ref) {
  const cam = useCameraService();
  const video = useRef<HTMLVideoElement>(null);
  const canvas = useRef<HTMLCanvasElement>(null);
  const ready = useRef(false);
  const [state, setState] = useState<"starting" | "ready" | "error">("starting");
  const [error, setError] = useState("");
  const [dims, setDims] = useState<[number, number]>([16, 9]);

  useEffect(() => {
    let cancelled = false;
    cam.acquire().then(async (stream) => {
      const v = video.current;
      if (cancelled || !v) return;
      v.srcObject = stream;                 // attach even when the stream already existed
      await v.play();
      if (cancelled) return;
      ready.current = true;
      setDims([v.videoWidth || 16, v.videoHeight || 9]);
      setState("ready");
    }).catch((e) => {
      if (cancelled) return;
      setState("error");
      setError(e?.name === "NotAllowedError" ? "Camera permission denied. Allow it in the browser address bar."
        : e?.name === "NotFoundError" ? "No camera found." : e?.message || "Camera error");
    });
    return () => {
      cancelled = true; ready.current = false;
      if (video.current) video.current.srcObject = null;
      cam.release();
    };
  }, [cam]);

  useImperativeHandle(ref, () => ({
    isReady: () => ready.current,
    capture: () => new Promise((resolve) => {
      const v = video.current, c = canvas.current;
      if (!ready.current || !v || !c || !v.videoWidth) return resolve(null);
      c.width = v.videoWidth; c.height = v.videoHeight;
      c.getContext("2d")!.drawImage(v, 0, 0);
      c.toBlob((b) => resolve(b), "image/jpeg", 0.92);
    }),
  }), []);

  const box = overlay && overlay.image?.[0]
    ? (() => {
        const [x1, y1, x2, y2] = overlay.bbox; const [w, h] = overlay.image;
        return { left: `${(1 - x2 / w) * 100}%`, top: `${(y1 / h) * 100}%`, width: `${((x2 - x1) / w) * 100}%`, height: `${((y2 - y1) / h) * 100}%` };
      })() : null;

  return (
    <div className={`relative w-full overflow-hidden rounded-xl bg-black ${className || ""}`} style={{ aspectRatio: `${dims[0]} / ${dims[1]}` }}>
      <video ref={video} muted playsInline className="h-full w-full -scale-x-100 object-fill" />
      <canvas ref={canvas} hidden />
      {box && overlay && (
        <div className={`absolute rounded-md border-2 ${TONE[overlay.tone || "good"].split(" ")[0]}`} style={box}>
          {overlay.label && <span className={`absolute -top-6 left-0 whitespace-nowrap rounded px-2 py-0.5 text-xs font-semibold text-white ${TONE[overlay.tone || "good"].split(" ")[1]}`}>{overlay.label}</span>}
        </div>
      )}
      {state !== "ready" && (
        <div className={`absolute inset-0 grid place-items-center bg-black/60 p-4 text-center text-sm ${state === "error" ? "text-red-200" : "text-white"}`}>
          {state === "error" ? error : "Starting camera..."}
        </div>
      )}
    </div>
  );
});
export default CameraView;
