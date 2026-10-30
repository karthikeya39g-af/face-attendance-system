import { useEffect, useState } from "react";
import { AlertTriangle, CalendarDays, Calculator, HeartPulse, Receipt, Save, ShieldCheck } from "lucide-react";
import { api, useApi } from "../lib/api";
import { Card, ErrorNote, Field, Loading, Note, PageHeader, SectionBar, Select } from "../components/ui";
import { useShell } from "../components/Layout";

const DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
const num = (v: string) => (v === "" ? null : Number(v));

export default function SettingsPage() {
  const { go } = useShell();
  const pol = useApi<any>("/api/settings/policy");
  const [p, setP] = useState<any>(null); const [msg, setMsg] = useState(""); const [err, setErr] = useState("");
  useEffect(() => { if (pol.data) setP(pol.data); }, [pol.data]);
  if (!p) return <div><PageHeader title="Settings" /><ErrorNote text={pol.error} /><Loading /></div>;
  const set = (k: string, v: any) => setP({ ...p, [k]: v });
  const save = async () => { setErr(""); setMsg(""); try { setP(await api.put("/api/settings/policy", p)); setMsg("Policy saved. It applies to attendance calculations immediately and to the next payroll calculation."); } catch (e: any) { setErr(e.message); } };
  const N = ({ k, label, step = "any", nullable }: { k: string; label: string; step?: string; nullable?: boolean }) => (
    <Field label={label}><input type="number" step={step} className="input" value={p[k] ?? ""} placeholder={nullable ? "none" : ""} onChange={(e) => set(k, nullable ? num(e.target.value) : Number(e.target.value))} /></Field>);
  const S = ({ k, label, opts }: { k: string; label: string; opts: [string, string][] }) => (
    <Field label={label}><Select aria-label={label} value={p[k]} onChange={(e) => set(k, e.target.value)}>{opts.map(([v, l]) => <option key={v} value={v}>{l}</option>)}</Select></Field>);
  return (
    <div>
      <PageHeader title="Settings" sub="Attendance and payroll policy" right={<button className="btn-primary" onClick={save}><Save className="h-4 w-4" />Save policy</button>} />
      <ErrorNote text={err} className="mb-3" />{msg && <div className="mb-3"><Note tone="green">{msg}</Note></div>}
      <div className="grid gap-4 lg:grid-cols-2">
        <Card className="p-4"><SectionBar icon={<CalendarDays className="h-5 w-5" />} title="Attendance rules" sub="Shift start/end, grace and break are set per shift in Shifts" /><div className="grid gap-3 sm:grid-cols-2">
          <div className="sm:col-span-2"><span className="label">Week-off days</span><div className="flex flex-wrap gap-3">{DAYS.map((d, i) => (<label key={d} className="flex items-center gap-1.5 text-sm"><input type="checkbox" checked={p.week_off_days.includes(i)} onChange={(e) => set("week_off_days", e.target.checked ? [...p.week_off_days, i].sort() : p.week_off_days.filter((x: number) => x !== i))} />{d}</label>))}</div></div>
          <N k="full_day_min_hours" label="Minimum hours for a full day" /><N k="half_day_min_hours" label="Minimum hours for a half day" />
          <N k="overtime_threshold_minutes" label="Overtime starts after (extra minutes)" step="1" /><N k="early_checkout_threshold_minutes" label="Early-checkout tolerance (minutes)" step="1" />
          <S k="missing_checkout_policy" label="Missing check-out (past days)" opts={[["assume_required", "Assume full required hours"], ["half_day", "Count as half day"], ["absent", "Count as absent"]]} /></div></Card>
        <Card className="p-4"><SectionBar icon={<Calculator className="h-5 w-5" />} title="Payroll rules" sub="Calculation defaults applied when payroll is calculated" /><div className="grid gap-3 sm:grid-cols-2">
          <S k="working_days_basis" label="Salary divisor (days in month)" opts={[["profile", "Employee's working days / month"], ["calendar_days", "Calendar days"], ["period_working_days", "Working days in period"]]} />
          <S k="deduction_base" label="Deduction base" opts={[["fixed_gross", "Basic + HRA + allowances"], ["basic", "Basic only"]]} />
          <S k="rounding" label="Rounding" opts={[["2dp", "2 decimals"], ["nearest_rupee", "Nearest rupee"]]} />
          <N k="overtime_multiplier" label="Overtime multiplier" /><N k="half_day_deduction_factor" label="Half-day deduction factor" />
          <label className="flex items-end gap-2 pb-2 text-sm"><input type="checkbox" checked={p.deduct_absent_days} onChange={(e) => set("deduct_absent_days", e.target.checked)} />Deduct pay for absent days</label></div></Card>
        <Card className="p-4 lg:col-span-2">
          <SectionBar icon={<ShieldCheck className="h-5 w-5" />} title="Provident fund (PF)" sub="Defaults are 0 — nothing is assumed." />
          <div className="grid gap-3 pb-5 sm:grid-cols-2 lg:grid-cols-3">
            <N k="pf_rate_percent" label="PF rate (%)" /><S k="pf_wage_basis" label="PF wage basis" opts={[["basic", "Basic"], ["fixed_gross", "Basic + HRA + allowances"]]} /><N k="pf_wage_ceiling" label="PF wage ceiling (₹)" nullable />
          </div>
          <SectionBar icon={<HeartPulse className="h-5 w-5" />} title="Employee state insurance (ESI)" sub="Defaults are 0 — nothing is assumed." />
          <div className="grid gap-3 pb-5 sm:grid-cols-2 lg:grid-cols-3">
            <N k="esi_rate_percent" label="ESI rate (%)" /><S k="esi_wage_basis" label="ESI wage basis" opts={[["gross", "Gross (incl. overtime/bonus)"], ["fixed_gross", "Fixed gross"]]} /><N k="esi_gross_ceiling" label="ESI applies only if fixed gross ≤ (₹)" nullable />
          </div>
          <SectionBar icon={<Receipt className="h-5 w-5" />} title="Professional tax" sub="Configured on each employee’s salary profile." />
          <div className="mb-5 flex flex-wrap items-center justify-between gap-3 rounded-xl border border-brand-200 bg-brand-50 p-4 text-sm text-slate-700">
            <span>Professional-tax amounts are stored per employee in their salary profile; there is no global rate in the current settings API.</span>
            <button type="button" className="btn-soft btn-sm" onClick={() => go("employees")}>Open employees</button>
          </div>
          <div className="flex items-start gap-2 rounded-xl border border-amber-200 bg-amber-50 p-4 text-sm text-amber-900">
            <AlertTriangle className="mt-0.5 h-4 w-4 shrink-0" />
            <p>This system does not know your legal obligations. Confirm rates and ceilings with your accountant or payroll advisor. PF/ESI apply only to employees with the corresponding toggle enabled in their salary profile.</p>
          </div>
        </Card>
      </div>
    </div>
  );
}
