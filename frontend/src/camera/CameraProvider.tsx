import { createContext, ReactNode, useContext, useMemo, useRef } from "react";

/**
 * One MediaStream for the whole app.
 *  - acquire(): ref-counts users and returns the EXISTING stream if there is one (never a second getUserMedia).
 *  - Every newly mounted <video> must attach the returned stream (CameraView does this).
 *  - release(): when nobody needs the camera, tracks are stopped after a short grace period, so moving
 *    Dashboard -> Enrollment -> Dashboard reuses the live stream instead of restarting it.
 */
type Ctx = { acquire: () => Promise<MediaStream>; release: () => void };
const CameraCtx = createContext<Ctx | null>(null);
const GRACE_MS = 2000;

export function CameraProvider({ children }: { children: ReactNode }) {
  const stream = useRef<MediaStream | null>(null);
  const starting = useRef<Promise<MediaStream> | null>(null);
  const users = useRef(0);
  const timer = useRef<number | undefined>(undefined);

  const api = useMemo<Ctx>(() => ({
    async acquire() {
      users.current += 1;
      window.clearTimeout(timer.current);
      if (stream.current && stream.current.active) return stream.current;
      if (!starting.current) {
        if (!navigator.mediaDevices?.getUserMedia) {
          users.current -= 1;
          throw new Error("Camera API unavailable. Use http://localhost or HTTPS.");
        }
        starting.current = navigator.mediaDevices
          .getUserMedia({ video: { width: { ideal: 1280 }, height: { ideal: 720 }, facingMode: "user" }, audio: false })
          .then((s) => { stream.current = s; return s; })
          .finally(() => { starting.current = null; });
      }
      try { return await starting.current; }
      catch (e) { users.current = Math.max(0, users.current - 1); throw e; }
    },
    release() {
      users.current = Math.max(0, users.current - 1);
      if (users.current === 0) {
        window.clearTimeout(timer.current);
        timer.current = window.setTimeout(() => {
          if (users.current === 0) { stream.current?.getTracks().forEach((t) => t.stop()); stream.current = null; }
        }, GRACE_MS);
      }
    },
  }), []);

  return <CameraCtx.Provider value={api}>{children}</CameraCtx.Provider>;
}

export function useCameraService() {
  const c = useContext(CameraCtx);
  if (!c) throw new Error("CameraProvider missing");
  return c;
}
