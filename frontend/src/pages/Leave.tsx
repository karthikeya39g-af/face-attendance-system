import { useState } from "react";
import { Check, Plus, X, Ban } from "lucide-react";
import { api, qs, useApi } from "../lib/api";
import { Badge, Card, Empty, ErrorNote, Field, Loading, Modal, Note, PageHeader, Select, StatusBadge, confirmAction } from "../components/ui";
import { isoDate } from "../lib/format";

export default function Leave() {
  const [status, setStatus] = useState("");
  const list = useApi<any[]>(`/api/leave/requests${qs({ status })}`);
  const types = useApi<any[]>("/api/leave/types");
  const [adding, setAdding] = useState(false); const [err, setErr] = useState("");
  const act = async (id: number, action: string) => {
    if (action !== "approve" && !confirmAction(`${action[0].toUpperCase() + action.slice(1)} this leave request?`)) return;
    try { await api.post(`/api/leave/requests/${id}/${action}`); list.reload(); } catch (e: any) { setErr(e.message); }
  };
  return (
    <div>
      <PageHeader title="Leave" sub="Approved leave marks employees ON LEAVE and feeds payroll (paid vs unpaid)" right={<>
        <Select aria-label="Leave status" className="!w-auto" value={status} onChange={(e) => setStatus(e.target.value)}><option value="">All statuses</option>{["PENDING", "APPROVED", "REJECTED", "CANCELLED"].map((s) => <option key={s}>{s}</option>)}</Select>
        <button className="btn-primary" onClick={() => setAdding(true)}><Plus className="h-4 w-4" />New request</button></>} />
      <div className="mb-3 flex flex-wrap gap-2">{(types.data || []).map((t) => <Badge key={t.code} tone={t.paid ? "green" : "red"}>{t.name} · {t.paid ? "paid" : "unpaid"}</Badge>)}</div>
      <ErrorNote text={list.error || err} className="mb-3" />
      <Card><div className="overflow-x-auto"><table className="tbl tbl-cards"><thead><tr><th>Employee</th><th>Type</th><th>From</th><th>To</th><th>Days</th><th>Reason</th><th>Status</th><th>Decided by</th><th /></tr></thead><tbody>
        {(list.data || []).map((r) => (<tr key={r.id}><td data-label="Employee">{r.name} <span className="text-xs text-slate-600">#{r.employee_code}</span></td><td data-label="Type">{r.leave_type_name}</td><td data-label="From">{r.start_date}</td><td data-label="To">{r.end_date}</td><td data-label="Days">{r.days}</td>
          <td data-label="Reason" className="max-w-[200px] truncate">{r.reason || "—"}</td><td data-label="Status"><StatusBadge s={r.status} /></td><td data-label="Decided by">{r.approved_by || "—"}</td>
          <td className="text-right"><div className="flex justify-end gap-1">
            {r.status === "PENDING" && <><button className="btn-primary btn-sm" onClick={() => act(r.id, "approve")}><Check className="h-3 w-3" />Approve</button>
              <button className="btn-ghost btn-sm" onClick={() => act(r.id, "reject")}><X className="h-3 w-3" />Reject</button></>}
            {["PENDING", "APPROVED"].includes(r.status) && <button className="btn-ghost btn-sm" onClick={() => act(r.id, "cancel")}><Ban className="h-3 w-3" />Cancel</button>}</div></td></tr>))}</tbody></table>
        {list.loading && !list.data && <Loading />}{list.data && !list.data.length && <Empty text="No leave requests" />}</div></Card>
      {adding && <NewLeave types={types.data || []} onClose={() => setAdding(false)} onDone={() => { setAdding(false); list.reload(); }} />}
    </div>
  );
}

function NewLeave({ types, onClose, onDone }: { types: any[]; onClose: () => void; onDone: () => void }) {
  const emps = useApi<any[]>("/api/admin/employees");
  const today = isoDate(new Date());
  const [f, setF] = useState({ employee_code: "", leave_type: "CASUAL", start_date: today, end_date: today, reason: "" }); const [err, setErr] = useState("");
  const save = async () => { try { await api.post("/api/leave/requests", { ...f, reason: f.reason || null }); onDone(); } catch (e: any) { setErr(e.message); } };
  return (<Modal title="New leave request" onClose={onClose}><div className="space-y-3">
    <Field label="Employee"><Select aria-label="Employee" value={f.employee_code} onChange={(e) => setF({ ...f, employee_code: e.target.value })}><option value="">Select...</option>
      {(emps.data || []).map((e) => <option key={e.employee_code} value={e.employee_code}>{e.name} (#{e.employee_code})</option>)}</Select></Field>
    <Field label="Leave type"><Select aria-label="Leave type" value={f.leave_type} onChange={(e) => setF({ ...f, leave_type: e.target.value })}>{types.map((t) => <option key={t.code} value={t.code}>{t.name} ({t.paid ? "paid" : "unpaid"})</option>)}</Select></Field>
    <div className="grid grid-cols-2 gap-3"><Field label="From"><input type="date" className="input" value={f.start_date} onChange={(e) => setF({ ...f, start_date: e.target.value })} /></Field>
      <Field label="To"><input type="date" className="input" value={f.end_date} onChange={(e) => setF({ ...f, end_date: e.target.value })} /></Field></div>
    <Field label="Reason (optional)"><input className="input" value={f.reason} onChange={(e) => setF({ ...f, reason: e.target.value })} /></Field>
    <Note>Days exclude week-offs and holidays. Overlapping requests are refused.</Note><ErrorNote text={err} />
    <div className="flex justify-end gap-2"><button className="btn-ghost" onClick={onClose}>Cancel</button><button className="btn-primary" disabled={!f.employee_code} onClick={save}>Submit</button></div></div></Modal>);
}
