import { useState } from "react";
import { Download } from "lucide-react";
import { api, qs, useApi } from "../lib/api";
import { fmtHM, fmtTime, isoDate } from "../lib/format";
import { Badge, Card, Empty, ErrorNote, Loading, PageHeader, Select, StatusBadge, CardHeader } from "../components/ui";
import { useShell } from "../components/Layout";

const STATUSES = ["", "PRESENT", "LATE", "HALF_DAY", "ABSENT", "ON_LEAVE", "HOLIDAY", "WEEK_OFF", "OVERTIME", "WORKING"];

export default function Attendance() {
  const { office, search } = useShell();
  const [day, setDay] = useState(isoDate(new Date()));
  const [status, setStatus] = useState("");
  const [from, setFrom] = useState(isoDate(new Date(Date.now() - 6 * 864e5)));
  const [to, setTo] = useState(isoDate(new Date()));
  const daily = useApi<any>(`/api/attendance/daily${qs({ day, office, status, q: search, limit: 500 })}`, { interval: 20000 });
  const events = useApi<any[]>("/api/admin/events?limit=15", { interval: 20000 });
  const [err, setErr] = useState("");
  const exportCsv = async () => { try { await api.download(`/api/reports/attendance${qs({ start: from, end: to, office, format: "csv" })}`, `attendance_${from}_${to}.csv`); } catch (e: any) { setErr(e.message); } };

  return (
    <div>
      <PageHeader title="Attendance" sub={daily.data ? `${daily.data.total} employees` : ""} />
      <Card className="mb-4 p-4"><div className="flex flex-wrap items-end gap-3">
        <div><span className="label">Date</span><input type="date" className="input" value={day} onChange={(e) => setDay(e.target.value)} /></div>
        <div><span className="label">Status</span><Select aria-label="Attendance status" value={status} onChange={(e) => setStatus(e.target.value)}>
          {STATUSES.map((s) => <option key={s} value={s}>{s ? s.replace("_", " ") : "All"}</option>)}</Select></div>
        <div className="ml-auto flex flex-wrap items-end gap-2"><div><span className="label">Export from</span><input type="date" className="input" value={from} onChange={(e) => setFrom(e.target.value)} /></div>
          <div><span className="label">to</span><input type="date" className="input" value={to} onChange={(e) => setTo(e.target.value)} /></div>
          <button className="btn-ghost" onClick={exportCsv}><Download className="h-4 w-4" />CSV</button></div></div>
        <p className="mt-2 text-xs text-slate-500">Office and name search use the filters in the top bar.</p></Card>
      <ErrorNote text={daily.error || err} className="mb-3" />
      <Card><div className="overflow-x-auto"><table className="tbl tbl-cards"><thead><tr><th>Employee</th><th>Office</th><th>Check in</th><th>Check out</th><th>Working hours</th><th>Late</th><th>Overtime</th><th>Status</th><th>Score</th></tr></thead><tbody>
        {(daily.data?.rows || []).map((r: any) => (<tr key={r.employee_code}>
          <td data-label="Employee">{r.name} <span className="text-xs text-slate-600">#{r.employee_code}</span></td><td data-label="Office">{r.office}</td><td data-label="Check in">{fmtTime(r.check_in)}</td>
          <td data-label="Check out">{r.currently_working ? <Badge tone="green">working</Badge> : r.incomplete ? <Badge tone="amber">missing</Badge> : fmtTime(r.check_out)}</td>
          <td data-label="Working hours">{fmtHM(r.worked_minutes)}</td><td data-label="Late">{r.late_minutes ? `${r.late_minutes}m` : "—"}</td><td data-label="Overtime">{r.overtime_minutes ? fmtHM(r.overtime_minutes) : "—"}</td>
          <td data-label="Status"><StatusBadge s={r.status} /></td><td data-label="Score">{r.score ?? "—"}</td></tr>))}</tbody></table>
        {daily.loading && !daily.data && <Loading />}{daily.data && !daily.data.rows.length && <Empty text="No records for these filters" />}</div></Card>
      <Card className="mt-4"><CardHeader title="Recent events" sub="Live audit log" /><div className="overflow-x-auto"><table className="tbl tbl-cards"><thead><tr><th>Time</th><th>Event</th><th>Employee id</th><th>Similarity</th></tr></thead><tbody>
        {(events.data || []).map((e) => (<tr key={e.id}><td data-label="Time">{new Date(e.created_at).toLocaleString("en-GB")}</td><td data-label="Event">{e.type.replace(/_/g, " ")}</td><td data-label="Employee id">{e.employee_id ?? "—"}</td><td data-label="Similarity">{e.similarity ?? "—"}</td></tr>))}</tbody></table>
        {!events.data?.length && <Empty text="No events yet" />}</div></Card>
    </div>
  );
}
