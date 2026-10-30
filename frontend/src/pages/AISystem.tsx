import { CheckCircle2, XCircle } from "lucide-react";
import { useApi } from "../lib/api";
import { fmtDateTime } from "../lib/format";
import { Card, CardHeader, Empty, ErrorNote, PageHeader, Badge } from "../components/ui";

export default function AISystem() {
  const health = useApi<any>("/health", { interval: 10000 });
  const models = useApi<any>("/api/system/models");
  const db = useApi<any>("/api/system/database", { interval: 15000 });
  const cfg = useApi<any>("/api/system/config");
  const sum = useApi<any>("/api/dashboard/summary", { interval: 20000 });
  const events = useApi<any[]>("/api/admin/events?limit=60", { interval: 15000 });
  const m = models.data;
  const problems = (events.data || []).filter((e) => ["UNKNOWN_FACE", "LIVENESS_REJECTED", "LOW_QUALITY"].includes(e.type)).slice(0, 12);
  const Ok = ({ ok, label }: { ok: boolean; label: string }) => <div className="flex items-center gap-2 py-1.5 text-sm">{ok ? <CheckCircle2 className="h-4 w-4 text-emerald-500" /> : <XCircle className="h-4 w-4 text-red-500" />}{label}</div>;
  const io = (x: any) => (x || []).map((p: any) => `${p[0]} [${p[1].join(", ")}]`).join(" · ");
  return (
    <div>
      <PageHeader title="AI system" sub="Models, thresholds and recognition health (administrators / developers)" />
      <ErrorNote text={models.error || health.error} className="mb-3" />
      <div className="grid gap-4 lg:grid-cols-3">
        <Card><CardHeader title="Status" /><div className="px-4 py-2">
          <Ok ok={!!health.data} label="API" /><Ok ok={!!db.data && !db.error} label="Database" /><Ok ok={!!health.data?.models_loaded} label="Models loaded" />
          <Ok ok={!!m?.detector} label="Detection - SCRFD 500M KPS" /><Ok ok={!!m?.liveness} label="Liveness - MiniFASNetV2" /><Ok ok={!!m?.recognizer} label="Recognition - w600k_mbf" />
          <div className="mt-2 text-xs text-slate-500">Gallery: {db.data?.gallery_employees ?? "—"} employees · embedding dim {m?.recognizer?.embedding_dim ?? "—"}</div></div></Card>
        <Card className="lg:col-span-2"><CardHeader title="Models" /><div className="space-y-3 p-4 text-xs">
          {m && [["Detection", m.detector], ["Liveness", m.liveness], ["Recognition", m.recognizer]].map(([n, x]: any) => (<div key={n}><div className="text-sm font-semibold">{n}</div>
            <div className="text-slate-500">in: {io(x.inputs)}</div><div className="text-slate-500">out: {io(x.outputs).slice(0, 220)}</div></div>))}</div></Card>
        <Card><CardHeader title="Thresholds (from .env)" /><div className="max-h-80 space-y-1 overflow-auto p-4 font-mono text-xs">
          {cfg.data && Object.entries(cfg.data).map(([k, v]) => <div key={k} className="flex justify-between gap-2"><span className="text-slate-500">{k}</span><span>{String(v)}</span></div>)}</div></Card>
        <Card><CardHeader title="Recognition today" /><div className="space-y-1 p-4 text-sm">
          {sum.data && <>{[["Recognized", sum.data.ai.recognized], ["Unknown faces", sum.data.ai.unknown], ["Spoof rejected", sum.data.ai.liveness_rejected], ["Low quality", sum.data.ai.low_quality], ["Avg confidence", sum.data.ai.average_confidence ?? "—"]].map(([k, v]) => <div key={k as string} className="flex justify-between border-b border-slate-100 py-1"><span className="text-slate-500">{k}</span><span className="font-medium">{v as any}</span></div>)}</>}</div></Card>
        <Card><CardHeader title="Recent rejected events" /><ul className="max-h-80 divide-y divide-slate-100 overflow-auto text-sm">
          {problems.map((e) => <li key={e.id} className="flex items-center justify-between px-4 py-2"><Badge tone={e.type === "LIVENESS_REJECTED" ? "red" : e.type === "UNKNOWN_FACE" ? "amber" : "slate"}>{e.type.replace(/_/g, " ").toLowerCase()}</Badge><span className="text-xs text-slate-400">{fmtDateTime(e.created_at)}</span></li>)}
          {!problems.length && <li><Empty text="Nothing rejected recently" /></li>}</ul></Card>
      </div>
    </div>
  );
}
