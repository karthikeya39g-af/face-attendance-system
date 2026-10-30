import { useCallback, useEffect, useState } from "react";

const KEY = (import.meta as any).env?.VITE_API_KEY || "";
const TIMEOUT_MS = 25000;

export class ApiError extends Error {
  status: number; code: string; details: any;
  constructor(message: string, status = 0, code = "ERROR", details: any = {}) {
    super(message); this.status = status; this.code = code; this.details = details;
  }
}

async function request<T = any>(path: string, init: RequestInit = {}, raw = false): Promise<T> {
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), TIMEOUT_MS);
  const headers: Record<string, string> = { ...(KEY ? { "X-API-Key": KEY } : {}), ...((init.headers as any) || {}) };
  try {
    const r = await fetch(path, { ...init, headers, signal: ctrl.signal });
    if (raw) {
      if (!r.ok) throw new ApiError(`HTTP ${r.status}`, r.status);
      return (await r.blob()) as any;
    }
    let body: any = null;
    try { body = await r.json(); } catch { /* empty */ }
    if (!r.ok) {
      const e = body?.error;
      throw new ApiError(e?.message || (typeof body?.detail === "string" ? body.detail : `Request failed (${r.status})`),
        r.status, e?.code || `HTTP_${r.status}`, e?.details || {});
    }
    return body as T;
  } catch (e: any) {
    if (e instanceof ApiError) throw e;
    if (e?.name === "AbortError") throw new ApiError("The server took too long to respond.", 0, "TIMEOUT");
    throw new ApiError("Cannot reach the backend. Is it running?", 0, "NETWORK");
  } finally { clearTimeout(timer); }
}

const json = (method: string, body?: any): RequestInit => ({
  method, headers: { "Content-Type": "application/json" }, body: body === undefined ? undefined : JSON.stringify(body),
});

export const api = {
  get: <T = any>(p: string) => request<T>(p),
  post: <T = any>(p: string, body?: any) => request<T>(p, json("POST", body ?? {})),
  put: <T = any>(p: string, body?: any) => request<T>(p, json("PUT", body)),
  patch: <T = any>(p: string, body?: any) => request<T>(p, json("PATCH", body)),
  del: <T = any>(p: string) => request<T>(p, { method: "DELETE" }),
  upload: <T = any>(p: string, blob: Blob, fields: Record<string, string> = {}) => {
    const fd = new FormData();
    Object.entries(fields).forEach(([k, v]) => fd.append(k, v));
    fd.append("file", blob, "frame.jpg");
    return request<T>(p, { method: "POST", body: fd });
  },
  async download(path: string, filename: string) {
    const blob: Blob = await request(path, {}, true);
    const a = document.createElement("a");
    a.href = URL.createObjectURL(blob); a.download = filename; a.click();
    setTimeout(() => URL.revokeObjectURL(a.href), 2000);
  },
};

export const qs = (o: Record<string, any>) => {
  const p = new URLSearchParams();
  Object.entries(o).forEach(([k, v]) => { if (v !== undefined && v !== null && v !== "") p.set(k, String(v)); });
  const s = p.toString();
  return s ? `?${s}` : "";
};

/** GET with loading/error state and optional polling. Pass null to skip. */
export function useApi<T = any>(path: string | null, opts: { interval?: number } = {}) {
  const [data, setData] = useState<T | null>(null);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(!!path);
  const load = useCallback(async (silent = false) => {
    if (!path) return;
    if (!silent) setLoading(true);
    try { setData(await api.get<T>(path)); setError(""); }
    catch (e: any) { setError(e.message); }
    finally { setLoading(false); }
  }, [path]);
  useEffect(() => {
    load();
    if (!opts.interval) return;
    const t = setInterval(() => load(true), opts.interval);
    return () => clearInterval(t);
  }, [load, opts.interval]);
  return { data, error, loading, reload: () => load(true) };
}

export const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));
