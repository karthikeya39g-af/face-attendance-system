import { useState } from "react";
import { Building2, Plus, Pencil } from "lucide-react";
import { api, useApi } from "../lib/api";
import { Card, Empty, ErrorNote, Field, Modal, PageHeader, SectionBar } from "../components/ui";

export default function Offices() {
  const list = useApi<any[]>("/api/offices");
  const [edit, setEdit] = useState<{ code: string; name: string; isNew: boolean } | null>(null);
  const [err, setErr] = useState("");
  const save = async () => {
    if (!edit) return; setErr("");
    try { edit.isNew ? await api.post("/api/offices", { code: edit.code, name: edit.name }) : await api.patch(`/api/offices/${edit.code}`, { code: edit.code, name: edit.name }); setEdit(null); list.reload(); }
    catch (e: any) { setErr(e.message); }
  };
  return (
    <div>
      <PageHeader title="Offices" right={<button className="btn-primary" onClick={() => setEdit({ code: "", name: "", isNew: true })}><Plus className="h-4 w-4" />Add office</button>} />
      <ErrorNote text={list.error} className="mb-3" />
      <Card><SectionBar icon={<Building2 className="h-5 w-5" />} title="Office locations" sub="Active employee counts from your workspace" />
        <div className="overflow-x-auto"><table className="tbl tbl-cards"><thead><tr><th>Code</th><th>Name</th><th>Active employees</th><th /></tr></thead><tbody>
        {(list.data || []).map((o) => (<tr key={o.code}><td data-label="Code" className="font-medium">{o.code}</td><td data-label="Name">{o.name}</td><td data-label="Active employees">{o.employees}</td>
          <td className="text-right"><button className="btn-ghost btn-sm" onClick={() => setEdit({ code: o.code, name: o.name, isNew: false })}><Pencil className="h-3 w-3" />Rename</button></td></tr>))}</tbody></table>
        {!list.data?.length && <Empty text="No offices" />}</div></Card>
      {edit && <Modal title={edit.isNew ? "Add office" : "Rename office"} onClose={() => setEdit(null)}><div className="space-y-3">
        <Field label="Code (letters, numbers, - _)"><input className="input" disabled={!edit.isNew} value={edit.code} onChange={(e) => setEdit({ ...edit, code: e.target.value })} /></Field>
        <Field label="Name"><input className="input" value={edit.name} onChange={(e) => setEdit({ ...edit, name: e.target.value })} /></Field>
        <ErrorNote text={err} /><div className="flex justify-end gap-2"><button className="btn-ghost" onClick={() => setEdit(null)}>Cancel</button><button className="btn-primary" disabled={!edit.code || !edit.name} onClick={save}>Save</button></div></div></Modal>}
    </div>
  );
}
