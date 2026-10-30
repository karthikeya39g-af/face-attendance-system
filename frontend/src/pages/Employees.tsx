import { useEffect, useState } from "react";
import { Plus, Trash2, UserPlus, Save } from "lucide-react";
import { api, useApi, ApiError } from "../lib/api";
import { fmtDateTime, fmtHM, inr } from "../lib/format";
import { Badge, Card, CardHeader, Drawer, Empty, ErrorNote, Field, Loading, Modal, Note, PageHeader, Select, StatusBadge, confirmAction } from "../components/ui";
import { useShell } from "../components/Layout";

export default function Employees() {
  const { office, search, go } = useShell();
  const list = useApi<any[]>("/api/admin/employees");
  const offices = useApi<any[]>("/api/offices");
  const [open, setOpen] = useState<string | null>(null);
  const [adding, setAdding] = useState(false);
  const [q, setQ] = useState(search);
  useEffect(() => setQ(search), [search]);
  const rows = (list.data || []).filter((e) => (!office || e.office === office) &&
    (!q || e.name.toLowerCase().includes(q.toLowerCase()) || e.employee_code.includes(q)));

  return (
    <div>
      <PageHeader title="Employees" sub={`${rows.length} shown`} right={<>
        <input className="input !w-56" placeholder="Search name or code" value={q} onChange={(e) => setQ(e.target.value)} />
        <button className="btn-primary" onClick={() => setAdding(true)}><Plus className="h-4 w-4" />Add employee</button></>} />
      <ErrorNote text={list.error} className="mb-3" />
      <Card><div className="overflow-x-auto"><table className="tbl tbl-cards"><thead><tr><th>Code</th><th>Name</th><th>Designation</th><th>Department</th><th>Office</th><th>Face enrollment</th><th /></tr></thead><tbody>
        {rows.map((e) => (<tr key={e.employee_code} className="cursor-pointer" onClick={() => setOpen(e.employee_code)}>
          <td data-label="Code" className="font-medium">{e.employee_code}</td>
          <td data-label="Name"><div><div className="font-semibold text-slate-900">{e.name}</div>{e.email && <div className="text-xs text-slate-500">{e.email}</div>}</div></td>
          <td data-label="Designation">{e.designation || <span className="text-slate-400">—</span>}</td>
          <td data-label="Department">{e.department ? <Badge tone="blue">{e.department}</Badge> : <span className="text-slate-400">—</span>}</td>
          <td data-label="Office">{e.office}</td>
          <td data-label="Face enrollment">{e.embedding_count > 0 ? <Badge tone="green">{e.embedding_count} samples</Badge> : <Badge tone="amber">not enrolled</Badge>}</td>
          <td className="text-right text-xs text-brand-700">View profile →</td></tr>))}</tbody></table>
        {list.loading && <Loading />}{!list.loading && rows.length === 0 && <Empty text="No employees found" />}</div></Card>
      {adding && <AddModal offices={offices.data || []} onClose={() => setAdding(false)} onDone={() => { setAdding(false); list.reload(); }} />}
      {open && <Profile code={open} onClose={() => setOpen(null)} onChanged={list.reload}
        enroll={(e: any) => { sessionStorage.setItem("enroll_prefill", JSON.stringify(e)); go("enrollment"); }} />}
    </div>
  );
}

function AddModal({ offices, onClose, onDone }: { offices: any[]; onClose: () => void; onDone: () => void }) {
  const [f, setF] = useState({
    employee_code: "",
    name: "",
    office_code: offices[0]?.code || "",
    designation: "",
    department: "",
    email: "",
    phone: "",
  });
  const [err, setErr] = useState("");
  const save = async () => {
    try {
      await api.post("/api/employees", {
        ...f,
        designation: f.designation || null,
        department: f.department || null,
        email: f.email || null,
        phone: f.phone || null,
      });
      onDone();
    } catch (e: any) {
      setErr(e.message);
    }
  };
  return (
    <Modal title="Add employee" onClose={onClose}><div className="space-y-3">
      <div className="grid grid-cols-2 gap-3">
        <Field label="Employee code *"><input className="input" placeholder="e.g. EMP001" value={f.employee_code} onChange={(e) => setF({ ...f, employee_code: e.target.value })} /></Field>
        <Field label="Full name *"><input className="input" placeholder="e.g. John Doe" value={f.name} onChange={(e) => setF({ ...f, name: e.target.value })} /></Field>
      </div>
      <div className="grid grid-cols-2 gap-3">
        <Field label="Designation"><input className="input" placeholder="e.g. Senior Engineer" value={f.designation} onChange={(e) => setF({ ...f, designation: e.target.value })} /></Field>
        <Field label="Department"><input className="input" placeholder="e.g. Engineering" value={f.department} onChange={(e) => setF({ ...f, department: e.target.value })} /></Field>
      </div>
      <div className="grid grid-cols-2 gap-3">
        <Field label="Email"><input type="email" className="input" placeholder="name@company.com" value={f.email} onChange={(e) => setF({ ...f, email: e.target.value })} /></Field>
        <Field label="Phone"><input type="tel" className="input" placeholder="+91 9876543210" value={f.phone} onChange={(e) => setF({ ...f, phone: e.target.value })} /></Field>
      </div>
      <Field label="Office *"><Select aria-label="Office" value={f.office_code} onChange={(e) => setF({ ...f, office_code: e.target.value })}>
        {offices.map((o) => <option key={o.code} value={o.code}>{o.name}</option>)}</Select></Field>
      <ErrorNote text={err} />
      <div className="flex justify-end gap-2"><button className="btn-ghost" onClick={onClose}>Cancel</button>
        <button className="btn-primary" disabled={!f.employee_code || !f.name || !f.office_code} onClick={save}>Create</button></div>
      <p className="text-xs text-slate-500">After creating, enroll the face from the profile or the Enrollment page.</p></div></Modal>
  );
}

const SAL = [["basic_salary", "Basic salary"], ["hra", "HRA"], ["transport_allowance", "Transport allowance"], ["medical_allowance", "Medical allowance"],
  ["special_allowance", "Special allowance"], ["other_allowance", "Other allowance"], ["overtime_rate", "Overtime rate (per hour)"],
  ["working_hours_per_day", "Working hours / day"], ["working_days_per_month", "Working days / month"], ["professional_tax", "Professional tax (monthly)"],
  ["other_fixed_deduction", "Other fixed deduction"]] as const;

function Profile({ code, onClose, onChanged, enroll }: { code: string; onClose: () => void; onChanged: () => void; enroll: (e: any) => void }) {
  const p = useApi<any>(`/api/employees/${code}/profile`);
  const [sal, setSal] = useState<any>(null);
  const [msg, setMsg] = useState(""); const [err, setErr] = useState("");
  useEffect(() => { if (p.data) setSal(p.data.salary_profile ? { ...p.data.salary_profile } : { basic_salary: 0, hra: 0, transport_allowance: 0, medical_allowance: 0, special_allowance: 0, other_allowance: 0, overtime_rate: 0, working_hours_per_day: 8, working_days_per_month: 26, pf_enabled: false, esi_enabled: false, professional_tax: 0, other_fixed_deduction: 0, effective_from: "" }); }, [p.data]);
  const d = p.data;
  const saveSal = async () => {
    setErr(""); setMsg("");
    try { const body = { ...sal, effective_from: sal.effective_from || undefined }; await api.put(`/api/employees/${code}/salary-profile`, body); setMsg("Salary profile saved"); p.reload(); }
    catch (e: any) { setErr(e.message); }
  };
  const deactivate = async () => {
    if (!confirmAction(`Deactivate ${d.employee.name}? Attendance and payroll history are kept.`)) return;
    try { await api.del(`/api/employees/${code}`); onChanged(); onClose(); } catch (e: any) { setErr(e.message); }
  };
  return (
    <Drawer title={d ? `${d.employee.name} (#${code})` : "Employee"} onClose={onClose}>
      <ErrorNote text={p.error} />{p.loading && !d && <Loading />}
      {d && sal && <>
        <Card><div className="grid grid-cols-2 gap-3 p-4 text-sm sm:grid-cols-4">
          <KV k="Designation" v={d.employee.designation || "—"} />
          <KV k="Department" v={d.employee.department ? <Badge tone="blue">{d.employee.department}</Badge> : "—"} />
          <KV k="Office" v={d.employee.office} /><KV k="Status" v={d.employee.is_active ? "Active" : "Inactive"} />
          <KV k="Email" v={d.employee.email || "—"} /><KV k="Phone" v={d.employee.phone || "—"} />
          <KV k="Face samples" v={d.face.embedding_count} /><KV k="Today" v={<StatusBadge s={d.today.status} />} /></div>
          <div className="flex gap-2 border-t border-slate-100 p-3">
            <button className="btn-ghost btn-sm" onClick={() => enroll({ code, name: d.employee.name, office: d.employee.office })}><UserPlus className="h-3.5 w-3.5" />{d.face.enrolled ? "Re-enroll face" : "Enroll face"}</button>
            <button className="btn-ghost btn-sm text-red-600" onClick={deactivate}><Trash2 className="h-3.5 w-3.5" />Deactivate</button></div></Card>

        <Card><CardHeader title="This month" /><div className="grid grid-cols-3 gap-3 p-4 text-sm sm:grid-cols-4">
          <KV k="Present" v={d.month.present} /><KV k="Half day" v={d.month.half_day} /><KV k="Absent" v={d.month.absent} /><KV k="On leave" v={d.month.on_leave} />
          <KV k="Late" v={d.month.late} /><KV k="Early out" v={d.month.early_checkout} /><KV k="Hours" v={d.month.total_hours} /><KV k="Overtime" v={`${d.month.overtime_hours} h`} /></div>
          <div className="max-h-48 overflow-auto border-t border-slate-100"><table className="tbl tbl-cards"><thead><tr><th>Date</th><th>Status</th><th>Worked</th><th>Late</th></tr></thead><tbody>
            {d.month.days.filter((x: any) => !["FUTURE"].includes(x.status)).map((x: any) => (<tr key={x.date}><td data-label="Date">{x.date}</td><td data-label="Status"><StatusBadge s={x.status} /></td>
              <td data-label="Worked">{fmtHM(x.worked_minutes)}</td><td data-label="Late">{x.late_minutes ? `${x.late_minutes}m` : "—"}</td></tr>))}</tbody></table></div></Card>

        <Card><CardHeader title="Salary profile" sub="Used by payroll. A new 'effective from' date keeps the old profile as history." />
          <div className="grid gap-3 p-4 sm:grid-cols-2">
            {SAL.map(([k, label]) => (<Field key={k} label={label}><input type="number" min="0" step="any" className="input" value={sal[k]} onChange={(e) => setSal({ ...sal, [k]: e.target.value === "" ? 0 : Number(e.target.value) })} /></Field>))}
            <Field label="Effective from"><input type="date" className="input" value={sal.effective_from} onChange={(e) => setSal({ ...sal, effective_from: e.target.value })} /></Field>
            <div className="flex items-end gap-4 pb-2 text-sm">
              <label className="flex items-center gap-2"><input type="checkbox" checked={sal.pf_enabled} onChange={(e) => setSal({ ...sal, pf_enabled: e.target.checked })} />PF enabled</label>
              <label className="flex items-center gap-2"><input type="checkbox" checked={sal.esi_enabled} onChange={(e) => setSal({ ...sal, esi_enabled: e.target.checked })} />ESI enabled</label></div></div>
          <div className="space-y-2 border-t border-slate-100 p-3"><ErrorNote text={err} />{msg && <Note tone="green">{msg}</Note>}
            <button className="btn-primary" onClick={saveSal}><Save className="h-4 w-4" />Save salary profile</button>
            <p className="text-xs text-slate-500">PF/ESI percentages are set once in Settings → Policy (default 0). Nothing statutory is assumed.</p></div></Card>

        <Card><CardHeader title="Latest payroll" />{d.latest_payroll ? <div className="grid grid-cols-2 gap-3 p-4 text-sm sm:grid-cols-4">
          <KV k="Gross" v={inr(d.latest_payroll.gross_salary)} /><KV k="Deductions" v={inr(d.latest_payroll.total_deductions)} />
          <KV k="Net" v={inr(d.latest_payroll.net_salary)} /><KV k="Status" v={<StatusBadge s={d.latest_payroll.status} />} /></div> : <Empty text="No payroll yet" />}</Card>

        <Card><CardHeader title="Recognition history" /><ul className="divide-y divide-slate-100 text-sm">
          {d.recent_events.map((e: any, i: number) => (<li key={i} className="flex justify-between px-4 py-2"><span>{e.type.replace(/_/g, " ").toLowerCase()}{e.similarity ? ` · ${e.similarity}` : ""}</span>
            <span className="text-xs text-slate-400">{fmtDateTime(e.at)}</span></li>))}{!d.recent_events.length && <li><Empty text="No events" /></li>}</ul></Card>
      </>}
    </Drawer>
  );
}
const KV = ({ k, v }: { k: string; v: any }) => <div><div className="text-xs text-slate-500">{k}</div><div className="font-medium">{v}</div></div>;
