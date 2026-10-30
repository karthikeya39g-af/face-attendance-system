import { useState } from "react";
import { Download, Play } from "lucide-react";
import { api, qs, useApi } from "../lib/api";
import { isoDate } from "../lib/format";
import { Card, Empty, ErrorNote, Field, Loading, Note, PageHeader, Select } from "../components/ui";
import { useShell } from "../components/Layout";

const REPORTS = [["attendance", "Attendance (daily, per employee)"], ["late", "Late arrivals"], ["overtime", "Overtime"], ["leave", "Leave"], ["payroll", "Payroll"], ["events", "Recognition events"]];

export default function Reports() {
  const { office } = useShell();
  const [name, setName] = useState("attendance");
  const [start, setStart] = useState(isoDate(new Date(Date.now() - 29 * 864e5))); const [end, setEnd] = useState(isoDate(new Date()));
  const [employee, setEmployee] = useState(""); const [period, setPeriod] = useState("");
  const periods = useApi<any[]>("/api/payroll/periods"); const emps = useApi<any[]>("/api/admin/employees");
  const [data, setData] = useState<any>(null); const [err, setErr] = useState(""); const [busy, setBusy] = useState(false);
  const params = { start, end, office, employee, period_id: period };
  const run = async () => { setBusy(true); setErr(""); try { setData(await api.get(`/api/reports/${name}${qs(params)}`)); } catch (e: any) { setErr(e.message); } finally { setBusy(false); } };
  const csv = () => api.download(`/api/reports/${name}${qs({ ...params, format: "csv" })}`, `${name}_report.csv`).catch((e) => setErr(e.message));

  return (
    <div>
      <PageHeader title="Reports" sub="Generated from live data. Export to CSV." />
      <Card className="mb-4 p-4"><div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-5">
        <Field label="Report"><Select aria-label="Report" value={name} onChange={(e) => { setName(e.target.value); setData(null); }}>{REPORTS.map(([k, l]) => <option key={k} value={k}>{l}</option>)}</Select></Field>
        {name !== "payroll" && name !== "events" && <><Field label="From"><input type="date" className="input" value={start} onChange={(e) => setStart(e.target.value)} /></Field>
          <Field label="To"><input type="date" className="input" value={end} onChange={(e) => setEnd(e.target.value)} /></Field></>}
        {name !== "payroll" && name !== "events" && <Field label="Employee"><Select aria-label="Employee" value={employee} onChange={(e) => setEmployee(e.target.value)}><option value="">All</option>{(emps.data || []).map((x) => <option key={x.employee_code} value={x.employee_code}>{x.name}</option>)}</Select></Field>}
        {name === "payroll" && <Field label="Payroll period"><Select aria-label="Payroll period" value={period} onChange={(e) => setPeriod(e.target.value)}><option value="">All periods</option>{(periods.data || []).map((x) => <option key={x.id} value={x.id}>{x.year}-{String(x.month).padStart(2, "0")} · {x.status}</option>)}</Select></Field>}
        <div className="flex items-end gap-2"><button className="btn-primary" onClick={run} disabled={busy}><Play className="h-4 w-4" />Run</button><button className="btn-ghost" onClick={csv}><Download className="h-4 w-4" />CSV</button></div></div>
        {office && <p className="mt-2 text-xs text-slate-500">Office filter from the top bar applies: {office}</p>}</Card>
      <ErrorNote text={err} className="mb-3" />{busy && <Loading />}
      {data && <Card><div className="flex items-center justify-between border-b border-slate-100 px-4 py-2 text-sm"><b>{data.count} rows</b>{data.count > 200 && <span className="text-slate-500">Showing first 200 — export CSV for all</span>}</div>
        <div className="max-h-[60vh] overflow-auto"><table className="tbl tbl-cards"><thead><tr>{data.columns.map((c: string) => <th key={c}>{c.replace(/_/g, " ")}</th>)}</tr></thead><tbody>
          {data.rows.slice(0, 200).map((r: any[], i: number) => <tr key={i}>{r.map((v, j) => <td key={j} data-label={data.columns[j]?.replace(/_/g, " ")}>{v === null || v === undefined ? "—" : typeof v === "object" ? JSON.stringify(v) : String(v)}</td>)}</tr>)}</tbody></table>
          {!data.rows.length && <Empty text="No rows for these filters" />}</div></Card>}
      {!data && !busy && <Note>Choose a report and click <b>Run</b>. PDF export is not included yet; CSV opens in Excel.</Note>}
    </div>
  );
}
