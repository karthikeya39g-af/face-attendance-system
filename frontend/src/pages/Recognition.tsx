import { useEffect, useRef, useState } from "react";
import { AlertTriangle, ArrowLeft, Bug, CheckCircle2, Clock3, LogIn, LogOut, Play, ScanFace, Sparkles, Square, XCircle } from "lucide-react";
import { api, sleep, useApi } from "../lib/api";
import { HINTS, fmtTime } from "../lib/format";
import CameraView, { CameraHandle, FaceOverlay } from "../camera/CameraView";
import Logo from "../components/Logo";
import { Badge, Card, CardHeader, Chip, Empty, ErrorNote, Loading, PageHeader } from "../components/ui";

const ACTION: Record<string, string> = { CHECK_IN: "Checked in", CHECK_OUT: "Checked out", ALREADY_CHECKED_IN: "Already checked in", ALREADY_CHECKED_OUT: "Already checked out", NO_CHECK_IN: "No check-in today" };
const INTERVAL_MS = 1000;

export default function Recognition({ kiosk = false, onBack }: { kiosk?: boolean; onBack?: () => void } = {}) {
  const cam = useRef<CameraHandle>(null);
  const run = useRef(false);
  const busy = useRef(false);
  const resetTimer = useRef<number | undefined>(undefined);
  const [scanning, setScanning] = useState(false);
  const [cameraReady, setCameraReady] = useState(false);
  const [debug, setDebug] = useState(false);
  const [res, setRes] = useState<any>(null);
  const [history, setHistory] = useState<any[]>([]);
  const [intent, setIntent] = useState<"CHECK_IN" | "CHECK_OUT">("CHECK_IN");
  const today = useApi<any[]>(kiosk ? "/api/attendance/today" : null, { interval: kiosk ? 10000 : undefined });
  const lastKey = useRef("");

  async function loop() {
    while (run.current) {
      const t0 = Date.now();
      if (!busy.current) {
        busy.current = true;
        try {
          const blob = await cam.current?.capture();
          if (blob) {
            const d = await api.upload("/api/face/recognize", blob);
            if (!run.current) return;
            setRes(d);
            const key = d.recognized ? `${d.employee.employee_code}:${d.attendance?.action}` : "";
            if (d.recognized && key !== lastKey.current) {
              lastKey.current = key;
              if (!kiosk) setHistory((h) => [{ t: new Date().toISOString(), name: d.employee.name, code: d.employee.employee_code, action: d.attendance?.action, score: d.score }, ...h].slice(0, 12));
            }
            if (kiosk && d.recognized) {
              run.current = false;
              setScanning(false);
              void today.reload();
              window.clearTimeout(resetTimer.current);
              resetTimer.current = window.setTimeout(() => {
                setRes(null);
                setScanning(true);
                run.current = true;
                void loop();
              }, 4500);
            }
          }
        } catch (e: any) { setRes({ recognized: false, reason: "api_error", error: e.message }); await sleep(1500); }
        finally { busy.current = false; }
      }
      await sleep(Math.max(100, INTERVAL_MS - (Date.now() - t0)));
    }
  }

  useEffect(() => {
    if (kiosk) {
      run.current = true;
      setScanning(true);
      void loop();
    }
    return () => {
      run.current = false;
      window.clearTimeout(resetTimer.current);
    };
  }, [kiosk]);
  useEffect(() => {
    if (!kiosk) return;
    const timer = window.setInterval(() => setCameraReady(!!cam.current?.isReady()), 250);
    return () => window.clearInterval(timer);
  }, [kiosk]);

  const toggle = () => {
    if (scanning) { run.current = false; setScanning(false); return; }
    run.current = true; setScanning(true); setRes(null); loop();
  };

  const state = !res ? "idle" : res.recognized ? "ok" : res.reason === "spoof_detected" ? "spoof" : ["face_too_small", "face_area_too_small", "image_too_blurry"].includes(res.reason) ? "quality"
    : ["below_threshold", "insufficient_margin"].includes(res.reason) ? "unknown" : "other";
  const tone = { ok: "good", spoof: "bad", unknown: "bad", quality: "warn", other: "warn", idle: "warn" }[state] as "good" | "warn" | "bad";
  const overlay: FaceOverlay = scanning && res?.bbox ? { bbox: res.bbox, image: res.image_size, tone,
    label: state === "ok" ? res.employee.name : state === "spoof" ? "SPOOF DETECTED" : state === "unknown" ? "UNKNOWN FACE" : state === "quality" ? "MOVE CLOSER / IMPROVE LIGHT" : "" } : null;

  const banner: Record<string, [string, string]> = {
    ok: ["bg-emerald-50 text-emerald-900", res?.employee ? `Matched · ${res.employee.name} · ${ACTION[res.attendance?.action] || "Recognized"}` : "Matched"],
    spoof: ["bg-rose-50 text-rose-900", "Not recognised · spoof detected"], unknown: ["bg-rose-50 text-rose-900", "Not recognised"],
    quality: ["bg-amber-50 text-amber-900", "Adjust your position or improve the lighting"],
    other: ["bg-slate-100 text-slate-800", HINTS[res?.reason] || res?.reason || res?.error || ""],
    idle: ["bg-brand-50 text-brand-800", "Scanning for a face..."],
  };
  const StateIcon = state === "ok" ? CheckCircle2 : state === "unknown" || state === "spoof" ? XCircle : state === "quality" || state === "other" ? AlertTriangle : ScanFace;

  if (kiosk) {
    const statusText = state === "ok" ? "Matched" : res ? "Not recognised" : scanning && cameraReady ? "Scanning" : "Ready";
    const markedRows = [...(today.data || [])].sort((a, b) =>
      String(b.check_out || b.check_in || "").localeCompare(String(a.check_out || a.check_in || "")));
    return <main className="min-h-screen bg-bg-deep px-4 pb-8 pt-4 text-ink sm:px-6">
      <div className="mx-auto max-w-2xl">
        <header className="relative flex min-h-16 items-center justify-center">
          <button type="button" aria-label="Back to role selection" onClick={onBack}
            className="btn-ghost absolute left-0 !h-11 !w-11 !p-0"><ArrowLeft className="h-5 w-5" /></button>
          <Logo size={34} withWordmark />
        </header>
        <h1 className="mt-3 text-center font-heading text-2xl font-semibold">Employee scan</h1>

        <div className="mx-auto mt-5 grid w-full max-w-sm grid-cols-2 rounded-full border border-brand-200 bg-white p-1 shadow-sm" aria-label="Attendance action">
          {(["CHECK_IN", "CHECK_OUT"] as const).map((action) => {
            const active = intent === action;
            const Icon = action === "CHECK_IN" ? LogIn : LogOut;
            return <button key={action} type="button" aria-pressed={active} onClick={() => setIntent(action)}
              className={`flex min-h-11 items-center justify-center gap-2 rounded-full px-3 text-sm font-semibold transition-colors ${active ? "bg-violet text-white" : "text-slate-700 hover:bg-brand-50"}`}>
              <Icon className="h-4 w-4" />{action === "CHECK_IN" ? "Check in" : "Check out"}
            </button>;
          })}
        </div>
        <p className="mt-2 text-center text-xs text-slate-600">The attendance service applies its existing rules using today’s verified attendance.</p>

        <section className={`scanner-shell mx-auto mt-5 max-w-xl ${scanning ? "is-scanning" : ""} ${state === "ok" ? "is-matched" : ["unknown", "spoof"].includes(state) ? "is-rejected" : ""}`}>
          <div className="scanner-gradient-ring">
            <div className="scanner-camera"><CameraView ref={cam} overlay={overlay} className="!rounded-[1.35rem]" /></div>
          </div>
          <span className="scanner-corner scanner-corner-tl" /><span className="scanner-corner scanner-corner-tr" />
          <span className="scanner-corner scanner-corner-bl" /><span className="scanner-corner scanner-corner-br" />
          <span className="scanner-face" aria-hidden="true"><StateIcon className="h-5 w-5 text-white" /></span>
          {scanning && <span className="scanner-line" aria-hidden="true" />}
        </section>

        <div role="status" aria-live="polite" className={`mx-auto mt-4 flex max-w-xl items-center justify-center gap-2 rounded-2xl border p-3 text-sm font-semibold ${
          state === "ok" ? "border-emerald-200 bg-emerald-50 text-emerald-900" :
          res ? "border-rose-200 bg-rose-50 text-rose-900" : "border-brand-200 bg-white text-brand-800"
        }`}>
          {scanning && !res ? <ScanFace className="h-5 w-5 animate-pulse" /> : <StateIcon className="h-5 w-5" />}
          {statusText}
          {res && !res.recognized && <span className="font-normal">· {HINTS[res.reason] || res.error || res.reason || "Try again"}</span>}
        </div>

        {res?.recognized && <Card className="mx-auto mt-4 max-w-xl p-5" aria-live="polite">
          <div className="flex items-start justify-between gap-4">
            <div><p className="text-xs font-semibold uppercase tracking-wide text-brand-700">Recognised employee</p>
              <h2 className="mt-1 font-heading text-xl font-semibold">{res.employee.name}</h2>
              <p className="mt-1 text-sm text-slate-600">{ACTION[res.attendance?.action] || "Recognized"}</p></div>
            <CheckCircle2 className="h-6 w-6 shrink-0 text-emerald-600" />
          </div>
          <div className="mt-4 grid grid-cols-2 gap-3 border-t border-brand-200 pt-4 text-sm">
            <div className="flex items-center gap-2 text-slate-700"><Clock3 className="h-4 w-4 text-brand-700" />{res.attendance?.time ? fmtTime(res.attendance.time) : "Time unavailable"}</div>
            <div className="text-right font-medium text-slate-700">Confidence {typeof res.score === "number" ? `${(res.score * 100).toFixed(1)}%` : "—"}</div>
          </div>
        </Card>}

        <Card className="mx-auto mt-5 max-w-xl">
          <CardHeader title="Attendance marked" sub="Today’s real attendance records" />
          {today.error && <ErrorNote text={today.error} className="m-4" />}
          {today.loading && !today.data && <Loading text="Loading attendance marks..." />}
          {!today.loading && !today.error && <ul className="divide-y divide-brand-200">
            {markedRows.map((row) => {
              const checkedOut = !!row.check_out;
              const markTime = row.check_out || row.check_in;
              return <li key={`${row.employee_code}-${row.date}`} className="flex items-center justify-between gap-3 px-5 py-3 text-sm">
                <div className="min-w-0"><p className="truncate font-medium text-ink">{row.name}</p>
                  <p className="text-xs text-slate-600">{checkedOut ? "Check out" : "Check in"} · #{row.employee_code}</p></div>
                <time className="shrink-0 tabular-nums text-slate-700">{markTime ? fmtTime(markTime) : "—"}</time>
              </li>;
            })}
            {!markedRows.length && <li><Empty text="No attendance marks today yet." /></li>}
          </ul>}
        </Card>
      </div>
    </main>;
  }

  return (
    <div>
      <PageHeader title="Live recognition" sub="Attendance is marked automatically after a verified match" right={<>
        <button className={debug ? "btn-primary btn-sm" : "btn-ghost btn-sm"} onClick={() => setDebug(!debug)}><Bug className="h-3.5 w-3.5" />Developer mode</button>
        <button className={scanning ? "btn-danger" : "btn-primary"} onClick={toggle}>{scanning ? <><Square className="h-4 w-4" />Stop</> : <><Play className="h-4 w-4" />Start scanning</>}</button></>} />
      <div className="grid gap-4 lg:grid-cols-3">
        <div className="space-y-3 lg:col-span-2">
          <div className={`scanner-shell ${scanning ? "is-scanning" : ""} ${state === "ok" ? "is-matched" : ["unknown", "spoof"].includes(state) ? "is-rejected" : ""}`}
            onPointerMove={(event) => {
              if (event.pointerType !== "mouse") return;
              const bounds = event.currentTarget.getBoundingClientRect();
              const x = (event.clientX - bounds.left) / bounds.width - 0.5;
              const y = (event.clientY - bounds.top) / bounds.height - 0.5;
              event.currentTarget.style.setProperty("--scanner-tilt-x", `${-y * 3}deg`);
              event.currentTarget.style.setProperty("--scanner-tilt-y", `${x * 3}deg`);
            }}
            onPointerLeave={(event) => {
              event.currentTarget.style.setProperty("--scanner-tilt-x", "0deg");
              event.currentTarget.style.setProperty("--scanner-tilt-y", "0deg");
            }}>
            <div className="scanner-gradient-ring">
              <div className="scanner-camera"><CameraView ref={cam} overlay={overlay} className="!rounded-[1.35rem]" /></div>
            </div>
            <span className="scanner-corner scanner-corner-tl" /><span className="scanner-corner scanner-corner-tr" />
            <span className="scanner-corner scanner-corner-bl" /><span className="scanner-corner scanner-corner-br" />
            <span className="scanner-face" aria-hidden="true"><StateIcon className="h-5 w-5 text-white" /></span>
            {scanning && <span className="scanner-line" aria-hidden="true" />}
          </div>
          {scanning && <div role="status" aria-live="polite" className={`flex items-start gap-3 rounded-2xl border p-4 text-base font-semibold ${banner[state][0]}`}>
            <StateIcon className="mt-0.5 h-5 w-5 shrink-0" /><div>{banner[state][1]}{state === "ok" && <Sparkles aria-hidden="true" className="ml-2 inline h-5 w-5 animate-pulse text-brand-700" />}
              {state === "ok" && <div className="mt-2 text-sm font-normal">#{res.employee.employee_code} · {res.employee.office} · match {res.score}{res.attendance?.message ? ` · ${res.attendance.message}` : ""}</div>}
              {res?.liveness && <div className="mt-3 flex flex-wrap gap-2"><Chip tone={res.liveness.label === "REAL" ? "teal" : "amber"}>Liveness · {res.liveness.label} ({res.liveness.score})</Chip>
                {res?.employee?.office && <Chip tone="sky">Office · {res.employee.office}</Chip>}</div>}</div></div>}
          {!scanning && <div className="flex items-start gap-3 rounded-2xl border border-brand-200 bg-brand-50 p-4 text-sm text-slate-700">
            <ScanFace className="mt-0.5 h-5 w-5 shrink-0 text-brand-700" /><span><strong className="text-brand-800">Ready to scan.</strong> Press <b>Start scanning</b>. Stand 50–80 cm from the camera with light on your face.</span>
          </div>}
        </div>
        <div className="space-y-4">
          <Card><CardHeader title="Session activity" />
            <ul className="divide-y divide-slate-100 text-sm">{history.map((h, i) => (<li key={i} className="flex items-center justify-between gap-2 px-4 py-2">
              <span>{h.name} <span className="text-xs text-slate-400">#{h.code}</span></span><span className="flex items-center gap-2"><Badge tone={h.action === "CHECK_IN" || h.action === "CHECK_OUT" ? "green" : "slate"}>{ACTION[h.action] || h.action}</Badge>
                <span className="text-xs text-slate-400">{fmtTime(h.t)}</span></span></li>))}{!history.length && <li><Empty text="No recognitions yet" /></li>}</ul></Card>
          {debug && res && <Card><CardHeader title="Developer details" /><div className="space-y-1 p-4 font-mono text-xs">
            <D k="recognized" v={String(res.recognized)} /><D k="reason" v={res.reason ?? "—"} /><D k="score" v={res.score ?? "—"} /><D k="second_score" v={res.second_score ?? "—"} /><D k="margin" v={res.margin ?? "—"} />
            <D k="liveness" v={res.liveness ? `${res.liveness.label} ${res.liveness.score}` : "—"} /><D k="face_score" v={res.face_score ?? "—"} />
            {res.quality && Object.entries(res.quality).map(([k, v]) => <D key={k} k={`quality.${k}`} v={String(v)} />)}
            {res.stats && Object.entries(res.stats).map(([k, v]) => <D key={k} k={`gallery.${k}`} v={String(v)} />)}</div></Card>}
        </div>
      </div>
    </div>
  );
}
const D = ({ k, v }: { k: string; v: any }) => <div className="flex justify-between gap-3"><span className="text-slate-500">{k}</span><span>{v}</span></div>;
