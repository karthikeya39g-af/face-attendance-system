import { useEffect, useState } from "react";
import { Bar, BarChart, CartesianGrid, Legend, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { Calculator, CheckCheck, Download, Plus, Send, Wallet } from "lucide-react";
import { api, qs, useApi } from "../lib/api";
import { fmtDateTime, inr, inrShort, monthName } from "../lib/format";
import { CHART_COLORS } from "../lib/theme";
import { Card, CardHeader, Empty, ErrorNote, Field, Loading, Modal, Note, PageHeader, Select, Stat, StatusBadge, Stepper, confirmAction } from "../components/ui";

const FLOW = ["DRAFT", "CALCULATED", "APPROVED", "PROCESSED", "PAID"];
const NEXT: Record<string, [string, string, string] | undefined> = {
  CALCULATED: ["approve", "Approve payroll", "Approve this payroll? It will be locked and can no longer be recalculated."],
  APPROVED: ["process", "Process payroll", "Mark this payroll as processed?"],
  PROCESSED: ["pay", "Mark as paid", "Mark this payroll as PAID? This is final."],
};

export default function Payroll() {
  const periods = useApi<any[]>("/api/payroll/periods");
  const dash = useApi<any>("/api/payroll/dashboard");
  const [sel, setSel] = useState<number | null>(null);
  const [creating, setCreating] = useState(false);
  useEffect(() => { if (sel === null && periods.data?.length) setSel(periods.data[0].id); }, [periods.data, sel]);
  const detail = useApi<any>(sel ? `/api/payroll/periods/${sel}` : null);
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState(""); const [info, setInfo] = useState<any>(null);
  const [rec, setRec] = useState<number | null>(null);
  const p = detail.data;

  const refresh = () => { periods.reload(); dash.reload(); detail.reload(); };
  const act = async (path: string, confirmMsg?: string) => {
    if (confirmMsg && !confirmAction(confirmMsg)) return;
    setBusy(true); setErr(""); setInfo(null);
    try { const r = await api.post(`/api/payroll/periods/${sel}/${path}`); if (path === "calculate") setInfo(r); refresh(); }
    catch (e: any) { setErr(e.message); } finally { setBusy(false); }
  };
  const exportCsv = () => api.download(`/api/reports/payroll${qs({ period_id: sel, format: "csv" })}`, `payroll_${p?.year}-${String(p?.month).padStart(2, "0")}.csv`).catch((e) => setErr(e.message));
  const t = p?.totals;
  const editable = p && ["DRAFT", "CALCULATED"].includes(p.status);
  const next = p ? NEXT[p.status] : undefined;

  return (
    <div>
      <PageHeader title="Payroll" sub="Built on verified attendance. Face recognition never decides salary." right={<>
        <Select aria-label="Payroll period" className="!w-auto" value={sel ?? ""} onChange={(e) => setSel(Number(e.target.value))}>
          {(periods.data || []).map((x) => <option key={x.id} value={x.id}>{monthName(x.month)} {x.year} · {x.status}</option>)}</Select>
        <button className="btn-ghost" onClick={() => setCreating(true)}><Plus className="h-4 w-4" />New period</button></>} />
      <ErrorNote text={periods.error || detail.error || err} className="mb-3" />
      {periods.loading && <Loading />}
      {!periods.loading && !periods.data?.length && <Card><Empty text="No payroll period yet. Click 'New period' to start." /></Card>}

      {p && <div className="space-y-4">
        <Card className="p-4"><div className="flex flex-wrap items-center justify-between gap-3">
          <Stepper steps={FLOW} current={FLOW.indexOf(p.status)} />
          <div className="flex flex-wrap gap-2">
            {(p.status === "DRAFT" || p.status === "CALCULATED") && <button className="btn-primary" disabled={busy} onClick={() => act("calculate")}><Calculator className="h-4 w-4" />{p.status === "DRAFT" ? "Calculate payroll" : "Recalculate"}</button>}
            {next && <button className="btn-primary" disabled={busy} onClick={() => act(next[0], next[2])}>{p.status === "PROCESSED" ? <Wallet className="h-4 w-4" /> : p.status === "APPROVED" ? <Send className="h-4 w-4" /> : <CheckCheck className="h-4 w-4" />}{next[1]}</button>}
            <button className="btn-ghost" onClick={exportCsv} disabled={!p.records?.length}><Download className="h-4 w-4" />Export CSV</button></div></div>
          <div className="mt-2 text-xs text-slate-500">{p.start_date} → {p.end_date}{p.approved_by ? ` · approved by ${p.approved_by}` : ""}{p.processed_by ? ` · processed by ${p.processed_by}` : ""}</div></Card>

        {info && <Note tone={info.skipped_no_salary_profile?.length ? "amber" : "green"}>Calculated {info.created + info.updated} employee(s).
          {info.skipped_no_salary_profile?.length > 0 && <> <b>No salary profile for: {info.skipped_no_salary_profile.join(", ")}</b> — add one in Employees → profile, then recalculate.</>}</Note>}

        <div className="grid grid-cols-2 gap-3 lg:grid-cols-6">
          <Stat label="Employees" value={t.employees} /><Stat label="Gross payroll" value={inrShort(t.gross)} tone="blue" /><Stat label="Total deductions" value={inrShort(t.deductions)} tone="red" />
          <Stat label="Net payroll" value={inrShort(t.net)} tone="green" /><Stat label="Overtime pay" value={inrShort(t.overtime_pay)} tone="violet" /><Stat label="Bonus" value={inrShort(t.bonus)} tone="amber" /></div>

        <Card><CardHeader title={`Payroll records · ${monthName(p.month)} ${p.year}`} sub="Click a row for the full calculation breakdown" />
          <div className="overflow-x-auto"><table className="tbl tbl-cards"><thead><tr><th>Employee</th><th>Basic</th><th>HRA</th><th>Allow.</th><th>OT</th><th>Bonus</th><th>Gross</th><th>PF</th><th>ESI</th><th>Tax</th><th>Other</th><th>Unpaid</th><th>Deductions</th><th>Net</th><th>Status</th></tr></thead><tbody>
            {p.records.map((r: any) => (<tr key={r.id} className="cursor-pointer" onClick={() => setRec(r.id)}>
              <td data-label="Employee">{r.name} <span className="text-xs text-slate-600">#{r.employee_code}</span></td>
              <td data-label="Basic" className="text-right tabular-nums">{inr(r.basic_salary)}</td><td data-label="HRA" className="text-right tabular-nums">{inr(r.hra)}</td><td data-label="Allowances" className="text-right tabular-nums">{inr(r.allowances)}</td><td data-label="Overtime" className="text-right tabular-nums">{inr(r.overtime_pay)}</td>
              <td data-label="Bonus" className="text-right tabular-nums">{inr(r.bonus)}</td><td data-label="Gross" className="text-right font-medium tabular-nums">{inr(r.gross_salary)}</td><td data-label="PF" className="text-right tabular-nums">{inr(r.pf_deduction)}</td><td data-label="ESI" className="text-right tabular-nums">{inr(r.esi_deduction)}</td><td data-label="Tax" className="text-right tabular-nums">{inr(r.professional_tax)}</td>
              <td data-label="Other" className="text-right tabular-nums">{inr(r.other_deductions)}</td><td data-label="Unpaid leave" className="text-right tabular-nums">{inr(r.unpaid_leave_deduction)}</td><td data-label="Deductions" className="text-right tabular-nums">{inr(r.total_deductions)}</td><td data-label="Net" className="text-right font-semibold tabular-nums">{inr(r.net_salary)}</td><td data-label="Status"><StatusBadge s={r.status} /></td></tr>))}</tbody></table>
            {!p.records.length && <Empty text="Nothing calculated yet. Employees need a salary profile first." />}</div></Card>

        <div className="grid gap-4 lg:grid-cols-2">
          <Card><CardHeader title="Payroll trend" /><div className="h-56 p-3">{dash.data?.trend?.length ? <ResponsiveContainer><BarChart data={dash.data.trend}>
            <CartesianGrid stroke="var(--subtle-border)" strokeDasharray="3 3" vertical={false} /><XAxis dataKey="period" fontSize={11} tick={{ fill: "var(--muted)" }} /><YAxis fontSize={11} tickFormatter={(v) => inrShort(v)} tick={{ fill: "var(--muted)" }} /><Tooltip formatter={(v: any) => inrShort(Number(v))} contentStyle={{ border: "1px solid var(--card-border)", borderRadius: 14, backgroundColor: "var(--surface)", color: "var(--ink)" }} /><Legend />
            <Bar dataKey="gross" fill={CHART_COLORS.violet} name="Gross" animationDuration={500} /><Bar dataKey="deductions" fill={CHART_COLORS.danger} name="Deductions" animationDuration={500} /><Bar dataKey="net" fill={CHART_COLORS.success} name="Net" animationDuration={500} /></BarChart></ResponsiveContainer> : <Empty />}</div></Card>
          <Card><CardHeader title="Audit trail" sub="Who did what, and when" /><ul className="max-h-56 divide-y divide-slate-100 overflow-auto text-sm">
            {p.audit.map((a: any, i: number) => (<li key={i} className="flex justify-between px-4 py-2"><span><b>{a.action.replace(/_/g, " ")}</b> <span className="text-slate-500">by {a.actor}</span></span><span className="text-xs text-slate-400">{fmtDateTime(a.at)}</span></li>))}
            {!p.audit.length && <li><Empty text="No activity" /></li>}</ul></Card>
        </div>
      </div>}

      {creating && <NewPeriod onClose={() => setCreating(false)} onDone={(id) => { setCreating(false); periods.reload(); setSel(id); }} />}
      {rec && <RecordModal id={rec} editable={!!editable} onClose={() => setRec(null)} onChanged={refresh} />}
    </div>
  );
}

function NewPeriod({ onClose, onDone }: { onClose: () => void; onDone: (id: number) => void }) {
  const d = new Date();
  const [y, setY] = useState(d.getFullYear()); const [m, setM] = useState(d.getMonth() + 1); const [err, setErr] = useState("");
  const go = async () => { try { const r = await api.post("/api/payroll/periods", { year: y, month: m }); onDone(r.id); } catch (e: any) { setErr(e.message); } };
  return (<Modal title="New payroll period" onClose={onClose}><div className="space-y-3">
    <div className="grid grid-cols-2 gap-3"><Field label="Month"><Select aria-label="Month" value={m} onChange={(e) => setM(Number(e.target.value))}>{Array.from({ length: 12 }, (_, i) => <option key={i} value={i + 1}>{monthName(i + 1)}</option>)}</Select></Field>
      <Field label="Year"><input type="number" className="input" value={y} onChange={(e) => setY(Number(e.target.value))} /></Field></div>
    <ErrorNote text={err} /><div className="flex justify-end gap-2"><button className="btn-ghost" onClick={onClose}>Cancel</button><button className="btn-primary" onClick={go}>Create</button></div></div></Modal>);
}

function RecordModal({ id, editable, onClose, onChanged }: { id: number; editable: boolean; onClose: () => void; onChanged: () => void }) {
  const r = useApi<any>(`/api/payroll/records/${id}`);
  const [f, setF] = useState({ type: "BONUS", description: "", amount: "" }); const [err, setErr] = useState(""); const [ok, setOk] = useState("");
  const add = async () => {
    setErr(""); setOk("");
    try { await api.post("/api/payroll/adjustments", { payroll_record_id: id, type: f.type, description: f.description, amount: Number(f.amount) });
      setOk("Adjustment saved. Click 'Recalculate' on the payroll page to apply it."); setF({ ...f, description: "", amount: "" }); r.reload(); onChanged(); }
    catch (e: any) { setErr(e.message); }
  };
  const d = r.data; const b = d?.breakdown;
  return (
    <Modal title={d ? `${d.name} (#${d.employee_code}) — payroll breakdown` : "Payroll record"} onClose={onClose} wide>
      <ErrorNote text={r.error} />{r.loading && !d && <Loading />}
      {d && <div className="space-y-4 text-sm">
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
          <KV k="Present days" v={d.present_days} /><KV k="Half days" v={d.half_days} /><KV k="Absent days" v={d.absent_days} /><KV k="Leave days" v={d.leave_days} />
          <KV k="Regular hours" v={d.regular_hours} /><KV k="Overtime hours" v={d.overtime_hours} /><KV k="Late count" v={d.late_count} /><KV k="Early checkouts" v={d.early_checkout_count} /></div>
        {d.missing_checkout_days > 0 && <Note tone="amber">{d.missing_checkout_days} day(s) had no check-out. They were treated per the missing-checkout policy — please review.</Note>}
        <table className="tbl"><tbody>
          <R k="Basic salary" v={d.basic_salary} /><R k="HRA" v={d.hra} /><R k="Allowances" v={d.allowances} /><R k="Overtime pay" v={d.overtime_pay} /><R k="Bonus / incentives" v={d.bonus} />
          <R k="Gross salary" v={d.gross_salary} bold /><R k="PF" v={-d.pf_deduction} /><R k="ESI" v={-d.esi_deduction} /><R k="Professional tax" v={-d.professional_tax} /><R k="Other deductions" v={-d.other_deductions} />
          <R k={`Unpaid leave / absence (${b.lop_days} days × ${inr(b.per_day_rate)})`} v={-d.unpaid_leave_deduction} /><R k="Total deductions" v={-d.total_deductions} bold />
          {d.reimbursement > 0 && <R k="Reimbursements" v={d.reimbursement} />}<R k="Net salary" v={d.net_salary} bold /></tbody></table>
        {b.negative_net && <Note tone="amber">Net salary is negative — deductions exceed earnings. Review before approving.</Note>}
        <div className="text-xs text-slate-500">Salary divisor: {b.salary_divisor} days ({b.divisor_basis}) · deduction base: {b.deduction_base} · overtime multiplier ×{b.overtime_multiplier}</div>
        <div><div className="mb-1 font-semibold">Adjustments</div>
          {d.adjustments.map((a: any) => <div key={a.id} className="flex justify-between border-b border-slate-100 py-1"><span>{a.type} · {a.description}</span><span>{inr(a.amount)}</span></div>)}
          {!d.adjustments.length && <div className="text-slate-400">None</div>}</div>
        {editable ? <div className="rounded-lg bg-slate-50 p-3"><div className="mb-2 font-semibold">Add adjustment</div>
          <div className="grid gap-2 sm:grid-cols-4"><Select aria-label="Adjustment type" value={f.type} onChange={(e) => setF({ ...f, type: e.target.value })}>{["BONUS", "INCENTIVE", "DEDUCTION", "REIMBURSEMENT", "OTHER"].map((t) => <option key={t}>{t}</option>)}</Select>
            <input className="input sm:col-span-2" placeholder="Description" value={f.description} onChange={(e) => setF({ ...f, description: e.target.value })} />
            <input className="input" type="number" step="any" placeholder="Amount" value={f.amount} onChange={(e) => setF({ ...f, amount: e.target.value })} /></div>
          <div className="mt-2 flex items-center gap-3"><button className="btn-primary btn-sm" disabled={!f.description || !f.amount} onClick={add}>Add</button><ErrorNote text={err} />{ok && <span className="text-emerald-700">{ok}</span>}</div>
          <p className="mt-1 text-xs text-slate-500">OTHER accepts a signed amount: positive adds to earnings, negative is a deduction.</p></div>
          : <Note>Payroll is locked — adjustments are no longer allowed.</Note>}
      </div>}
    </Modal>
  );
}
const KV = ({ k, v }: { k: string; v: any }) => <div><div className="text-xs text-slate-500">{k}</div><div className="font-medium">{v}</div></div>;
const R = ({ k, v, bold }: { k: string; v: number; bold?: boolean }) => <tr className={bold ? "bg-slate-50 font-semibold" : ""}><td>{k}</td><td className="text-right">{inr(v)}</td></tr>;
