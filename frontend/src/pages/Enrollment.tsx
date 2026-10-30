import { useEffect, useRef, useState } from "react";
import { CheckCircle2, XCircle, Camera as CamIcon } from "lucide-react";
import { api, sleep, useApi } from "../lib/api";
import { HINTS } from "../lib/format";
import CameraView, { CameraHandle } from "../camera/CameraView";
import { Card, CardHeader, ErrorNote, Field, Note, PageHeader, Select } from "../components/ui";
import { useShell } from "../components/Layout";

const POSES = ["Look straight at the camera", "Turn your head slightly LEFT", "Turn your head slightly RIGHT", "Tilt your chin slightly UP", "Tilt your chin slightly DOWN",
  "Small smile", "Neutral face", "Move a little closer", "Move a little back", "Look straight again", "Turn slightly LEFT again", "Turn slightly RIGHT again",
  "Relax, look straight", "Slight smile", "Last one - look straight"];
const CAPTURE_EVERY_MS = 1400;
const MAX_ATTEMPTS = 300;

function explain(e: any) {
  if (e.code === "TOO_SIMILAR_TO_EXISTING_EMPLOYEE") return `This face is already enrolled as employee ${e.details?.employee_code} (similarity ${e.details?.similarity}). One person cannot have two codes.`;
  if (e.code === "INCONSISTENT_SAMPLES") return "The samples did not look like the same person. Please try again.";
  return e.message;
}

export default function Enrollment() {
  const { go } = useShell();
  const offices = useApi<any[]>("/api/offices");
  const cam = useRef<CameraHandle>(null);
  const run = useRef(false);     // loop is active
  const busy = useRef(false);    // never two sample requests at once
  const sid = useRef<string | null>(null);
  const [form, setForm] = useState({ code: "", name: "", office: "" });
  const [phase, setPhase] = useState<"form" | "capturing" | "saving" | "done" | "error">("form");
  const [count, setCount] = useState({ captured: 0, target: 15 });
  const [log, setLog] = useState<any[]>([]);
  const [err, setErr] = useState("");
  const [result, setResult] = useState<any>(null);

  useEffect(() => {
    const pre = sessionStorage.getItem("enroll_prefill");
    if (pre) { try { const p = JSON.parse(pre); setForm((f) => ({ ...f, code: p.code, name: p.name, office: p.office })); } catch { /* ignore */ } sessionStorage.removeItem("enroll_prefill"); }
    return () => { run.current = false; if (sid.current) api.post(`/api/enrollment/cancel/${sid.current}`).catch(() => {}); };
  }, []);
  useEffect(() => { if (!form.office && offices.data?.length) setForm((f) => ({ ...f, office: offices.data![0].code })); }, [offices.data, form.office]);

  async function start() {
    setErr(""); setResult(null); setLog([]);
    try {
      const s = await api.post("/api/enrollment/start", { employee_code: form.code.trim(), name: form.name.trim(), office_code: form.office });
      sid.current = s.session_id; setCount({ captured: 0, target: s.target }); setPhase("capturing");
      run.current = true; loop();
    } catch (e: any) { setErr(explain(e)); }
  }

  async function loop() {
    let attempts = 0;
    while (run.current) {
      const t0 = Date.now();
      if (!busy.current) {
        busy.current = true;
        try {
          if (++attempts > MAX_ATTEMPTS) { fail("Too many attempts. Check lighting/camera and try again."); return; }
          const blob = await cam.current?.capture();
          if (blob && run.current) {
            const d = await api.upload("/api/enrollment/sample", blob, { session_id: sid.current! });
            if (!run.current) return;
            setCount({ captured: d.captured, target: d.target });
            setLog((l) => [{ ok: d.accepted, n: d.captured, reason: d.reason, q: d.quality, live: d.liveness, cons: d.consistency, t: Date.now() }, ...l].slice(0, 30));
            if (d.accepted && d.ready) { busy.current = false; await finish(); return; }
          }
        } catch (e: any) { fail(explain(e)); return; }
        finally { busy.current = false; }
      }
      await sleep(Math.max(100, CAPTURE_EVERY_MS - (Date.now() - t0)));
    }
  }
  async function finish() {
    run.current = false; setPhase("saving");
    try { const r = await api.post("/api/enrollment/complete", { session_id: sid.current }); sid.current = null; setResult(r); setPhase("done"); }
    catch (e: any) { fail(explain(e)); }
  }
  function fail(m: string) { run.current = false; setErr(m); setPhase("error"); }
  async function stop() { run.current = false; if (sid.current) await api.post(`/api/enrollment/cancel/${sid.current}`).catch(() => {}); sid.current = null; setPhase("form"); }

  const active = phase === "capturing" || phase === "saving";
  const pct = Math.round((count.captured / count.target) * 100);
  const last = log[0];

  return (
    <div>
      <PageHeader title="Face enrollment" sub="Collect varied, high-quality samples. Existing data is replaced only after the new set passes validation." />
      <div className="grid gap-4 lg:grid-cols-3">
        <div className="space-y-3 lg:col-span-2">
          <CameraView ref={cam} />
          {active && <Card className="p-4"><div className="mb-2 flex items-end justify-between"><div className="text-3xl font-bold">{count.captured} <span className="text-lg font-medium text-slate-400">/ {count.target}</span></div>
            <div className="text-right text-sm font-medium text-brand-700">{phase === "saving" ? "Saving..." : POSES[Math.min(count.captured, POSES.length - 1)]}</div></div>
            <div className="h-3 overflow-hidden rounded-full bg-white/10"><div className="veridant-progress-fill h-full rounded-full transition-all" style={{ width: `${pct}%` }} /></div>
            {last && !last.ok && <div className="mt-3 rounded-lg bg-amber-50 p-2 text-sm text-amber-800">Rejected: {HINTS[last.reason] || last.reason}</div>}</Card>}
          {phase === "done" && result && <Note tone="green"><b>Enrolled {result.name} (#{result.employee_code})</b> with {result.samples_saved} samples. <button className="ml-2 underline" onClick={() => go("recognition")}>Test recognition →</button></Note>}
          <ErrorNote text={err} />
        </div>
        <div className="space-y-4">
          <Card><CardHeader title="Employee" /><div className="space-y-3 p-4">
            <Field label="Employee code"><input className="input" disabled={active} value={form.code} onChange={(e) => setForm({ ...form, code: e.target.value })} /></Field>
            <Field label="Name"><input className="input" disabled={active} value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} /></Field>
            <Field label="Office"><Select aria-label="Office" disabled={active} value={form.office} onChange={(e) => setForm({ ...form, office: e.target.value })}>
              {(offices.data || []).map((o) => <option key={o.code} value={o.code}>{o.name}</option>)}</Select></Field>
            {!active ? <button className="btn-primary w-full" disabled={!form.code || !form.name || !form.office} onClick={start}><CamIcon className="h-4 w-4" />Start enrollment</button>
              : <button className="btn-danger w-full" onClick={stop}>Cancel</button>}
            <p className="text-xs text-slate-500">Good light on your face, 50–80 cm from the camera, and move your head a little between samples. One sample is taken about every 1.4 s.</p></div></Card>
          {log.length > 0 && <Card><CardHeader title="Samples" /><ul className="max-h-80 divide-y divide-slate-100 overflow-auto text-sm">
            {log.map((l) => (<li key={l.t} className="flex items-start gap-2 px-4 py-2">{l.ok ? <CheckCircle2 className="mt-0.5 h-4 w-4 shrink-0 text-emerald-500" /> : <XCircle className="mt-0.5 h-4 w-4 shrink-0 text-red-400" />}
              <div>{l.ok ? <><div className="font-medium">Accepted #{l.n}</div><div className="text-xs text-slate-500">face {Math.round(l.q.face_width)}×{Math.round(l.q.face_height)} · blur {l.q.blur_score} · live {l.live.score}{l.cons != null ? ` · consistency ${l.cons}` : ""}</div></>
                : <div className="text-slate-600">{HINTS[l.reason] || l.reason}</div>}</div></li>))}</ul></Card>}
        </div>
      </div>
    </div>
  );
}
