import { useState } from "react";
import { CalendarClock, CalendarDays, Plus, Trash2, Users } from "lucide-react";
import { api, useApi } from "../lib/api";
import { Badge, Card, Empty, ErrorNote, Field, PageHeader, SectionBar, Select, confirmAction } from "../components/ui";
import { isoDate } from "../lib/format";

export default function Shifts() {
  const shifts = useApi<any[]>("/api/shifts"); const assigns = useApi<any[]>("/api/shifts/assignments");
  const holidays = useApi<any[]>("/api/holidays"); const emps = useApi<any[]>("/api/admin/employees");
  const [err, setErr] = useState("");
  const [s, setS] = useState({ name: "", start_time: "09:00", end_time: "18:00", break_minutes: 60, grace_minutes: 15, required_hours: 8, is_default: false });
  const [a, setA] = useState({ employee_code: "", shift_id: 0, effective_from: isoDate(new Date()) });
  const [h, setH] = useState({ holiday_date: isoDate(new Date()), name: "" });
  const run = async (fn: () => Promise<any>, after: () => void) => { setErr(""); try { await fn(); after(); } catch (e: any) { setErr(e.message); } };

  return (
    <div>
      <PageHeader title="Shifts & holidays" sub="Shift times drive late, early-checkout, working hours and overtime" />
      <ErrorNote text={err || shifts.error} className="mb-3" />
      <div className="grid gap-4 lg:grid-cols-2">
        <Card><SectionBar icon={<CalendarClock className="h-5 w-5" />} title="Work shifts" sub="Shift rules used to calculate attendance and overtime" /><div className="overflow-x-auto"><table className="tbl tbl-cards"><thead><tr><th>Name</th><th>Time</th><th>Break</th><th>Grace</th><th>Required</th></tr></thead><tbody>
          {(shifts.data || []).map((x) => (<tr key={x.id}><td data-label="Name">{x.name} {x.is_default && <Badge tone="blue">default</Badge>}</td><td data-label="Time">{x.start_time}–{x.end_time}</td><td data-label="Break">{x.break_minutes}m</td><td data-label="Grace">{x.grace_minutes}m</td><td data-label="Required">{x.required_hours}h</td></tr>))}</tbody></table></div>
          <div className="grid gap-2 border-t border-slate-100 p-4 sm:grid-cols-3">
            <Field label="Name" className="sm:col-span-3"><input className="input" value={s.name} onChange={(e) => setS({ ...s, name: e.target.value })} /></Field>
            <Field label="Start"><input type="time" className="input" value={s.start_time} onChange={(e) => setS({ ...s, start_time: e.target.value })} /></Field>
            <Field label="End"><input type="time" className="input" value={s.end_time} onChange={(e) => setS({ ...s, end_time: e.target.value })} /></Field>
            <Field label="Required hours"><input type="number" step="0.25" className="input" value={s.required_hours} onChange={(e) => setS({ ...s, required_hours: Number(e.target.value) })} /></Field>
            <Field label="Break (min)"><input type="number" className="input" value={s.break_minutes} onChange={(e) => setS({ ...s, break_minutes: Number(e.target.value) })} /></Field>
            <Field label="Grace (min)"><input type="number" className="input" value={s.grace_minutes} onChange={(e) => setS({ ...s, grace_minutes: Number(e.target.value) })} /></Field>
            <label className="flex items-end gap-2 pb-2 text-sm"><input type="checkbox" checked={s.is_default} onChange={(e) => setS({ ...s, is_default: e.target.checked })} />Make default</label>
            <button className="btn-primary sm:col-span-3" disabled={!s.name} onClick={() => run(() => api.post("/api/shifts", s), () => { setS({ ...s, name: "" }); shifts.reload(); })}><Plus className="h-4 w-4" />Add shift</button></div>
          <p className="px-4 pb-3 text-xs text-slate-500">Overnight shifts (end earlier than start) are not supported yet.</p></Card>

        <Card><SectionBar icon={<Users className="h-5 w-5" />} title="Assign shift to employee" sub="Employees without an assignment use the default shift" />
          <div className="grid gap-2 p-4 sm:grid-cols-3">
            <Field label="Employee"><Select aria-label="Employee" value={a.employee_code} onChange={(e) => setA({ ...a, employee_code: e.target.value })}><option value="">Select...</option>{(emps.data || []).map((e) => <option key={e.employee_code} value={e.employee_code}>{e.name}</option>)}</Select></Field>
            <Field label="Shift"><Select aria-label="Shift" value={a.shift_id} onChange={(e) => setA({ ...a, shift_id: Number(e.target.value) })}><option value={0}>Select...</option>{(shifts.data || []).map((x) => <option key={x.id} value={x.id}>{x.name}</option>)}</Select></Field>
            <Field label="Effective from"><input type="date" className="input" value={a.effective_from} onChange={(e) => setA({ ...a, effective_from: e.target.value })} /></Field>
            <button className="btn-primary sm:col-span-3" disabled={!a.employee_code || !a.shift_id} onClick={() => run(() => api.post("/api/shifts/assign", a), assigns.reload)}>Assign</button></div>
          <div className="max-h-56 overflow-auto border-t border-slate-100"><table className="tbl tbl-cards"><thead><tr><th>Employee</th><th>Shift</th><th>From</th><th>To</th></tr></thead><tbody>
            {(assigns.data || []).map((x) => <tr key={x.id}><td data-label="Employee">{x.name}</td><td data-label="Shift">{x.shift}</td><td data-label="From">{x.effective_from}</td><td data-label="To">{x.effective_to || "open"}</td></tr>)}</tbody></table>{!assigns.data?.length && <Empty text="No assignments" />}</div></Card>

        <Card className="lg:col-span-2"><SectionBar icon={<CalendarDays className="h-5 w-5" />} title="Holidays" sub="Holidays are paid days and are never counted as absent" />
          <div className="flex flex-wrap items-end gap-2 p-4"><Field label="Date"><input type="date" className="input" value={h.holiday_date} onChange={(e) => setH({ ...h, holiday_date: e.target.value })} /></Field>
            <Field label="Name" className="min-w-[200px] flex-1"><input className="input" value={h.name} onChange={(e) => setH({ ...h, name: e.target.value })} /></Field>
            <button className="btn-primary" disabled={!h.name} onClick={() => run(() => api.post("/api/holidays", h), () => { setH({ ...h, name: "" }); holidays.reload(); })}><Plus className="h-4 w-4" />Add</button></div>
          <div className="max-h-64 overflow-auto border-t border-slate-100"><table className="tbl tbl-cards"><thead><tr><th>Date</th><th>Holiday</th><th /></tr></thead><tbody>
            {(holidays.data || []).map((x) => (<tr key={x.id}><td data-label="Date">{x.date}</td><td data-label="Holiday">{x.name}</td><td className="text-right"><button aria-label={`Delete ${x.name}`} className="btn-ghost btn-sm text-rose-800" onClick={() => confirmAction(`Delete ${x.name}?`) && run(() => api.del(`/api/holidays/${x.id}`), holidays.reload)}><Trash2 className="h-3 w-3" /></button></td></tr>))}</tbody></table>
            {!holidays.data?.length && <Empty text="No holidays configured" />}</div></Card>
      </div>
    </div>
  );
}
