import {
  Area, Bar, BarChart, CartesianGrid, ComposedChart, Legend, Line, ResponsiveContainer, Tooltip, XAxis, YAxis,
} from "recharts";
import {
  Activity, AlarmClock, Briefcase, CalendarOff, Clock, LogOut, TimerReset, UserCheck, UserMinus, UserPlus,
  UserRoundCheck, UserX, Users, Wallet,
} from "lucide-react";
import { useApi, qs } from "../lib/api";
import { fmtHM, fmtTime, greeting, inrShort, monthName } from "../lib/format";
import { CHART_COLORS } from "../lib/theme";
import {
  Avatar, Card, CardHeader, Empty, ErrorNote, Loading, PageHeader, Skeleton, Stat, StatusBadge,
} from "../components/ui";
import { useShell } from "../components/Layout";
import { SectionBar } from "../components/ui";

export default function Dashboard() {
  const { office, search, go } = useShell();
  const sum = useApi<any>(`/api/dashboard/summary${qs({ office })}`, { interval: 15000 });
  const daily = useApi<any>(`/api/attendance/daily${qs({ office, q: search, limit: 8 })}`, { interval: 15000 });
  const events = useApi<any[]>("/api/admin/events?limit=8", { interval: 15000 });
  const pendingLeaves = useApi<any[]>("/api/leave/requests?status=PENDING", { interval: 30000 });
  const s = sum.data;
  const pay = s?.payroll;
  const per = pay?.current_period;
  const trend = (s?.trend || []).map((day: any) => ({ ...day, day: day.date.slice(5) }));

  if (sum.loading && !s) return <Loading text="Loading dashboard..." />;

  return (
    <div className="space-y-6">
      {s ? (
        <section className="relative overflow-hidden rounded-3xl border border-brand-200 bg-white p-5 shadow-card sm:p-7">
          <span aria-hidden="true" className="absolute inset-y-0 left-0 w-1.5 bg-violet" />
          <div className="flex flex-col justify-between gap-6 lg:flex-row lg:items-end">
            <div className="max-w-2xl">
              <div className="mb-3 inline-flex items-center gap-2 rounded-full bg-brand-100 px-3 py-1.5 text-xs font-semibold text-brand-700">
                <span className="h-2 w-2 rounded-full bg-violet" /> Your workforce at a glance
              </div>
              <h1 className="text-2xl font-semibold tracking-tight text-ink sm:text-[26px]">{greeting()}, Admin 👋</h1>
              <p className="mt-2 text-sm text-slate-700">
                {new Date(s.date).toLocaleDateString("en-GB", { weekday: "long", day: "numeric", month: "long", year: "numeric" })}
              </p>
            </div>
            <div className="flex flex-wrap gap-2">
              <button type="button" className="btn-primary" onClick={() => go("attendance")}><UserCheck className="h-4 w-4" />Mark attendance</button>
              <button type="button" className="btn-soft" onClick={() => go("employees")}><UserPlus className="h-4 w-4" />Add employee</button>
              <button type="button" className="btn-ghost border border-brand-200" onClick={() => go("payroll")}><Wallet className="h-4 w-4" />Run payroll</button>
            </div>
          </div>
        </section>
      ) : (
        <>
          <PageHeader title={`${greeting()}, Admin`} sub="Your workforce overview" />
          <ErrorNote text={sum.error || "Dashboard summary is unavailable."} />
          <button type="button" className="btn-primary" onClick={() => sum.reload()}>Try again</button>
        </>
      )}

      {s && (
        <>
          <ErrorNote text={sum.error} />
          <Section title="Workforce" icon={<Users className="h-4 w-4" />}>
            <Stat label="Total employees" value={s.employees.total} icon={<Users className="h-5 w-5" />} tone="blue" />
            <Stat label="Active" value={s.employees.active} icon={<UserRoundCheck className="h-5 w-5" />} tone="green" />
            <Stat label="Inactive" value={s.employees.inactive} icon={<UserMinus className="h-5 w-5" />} />
            <Stat label="New this month" value={s.employees.new_this_month} icon={<UserPlus className="h-5 w-5" />} tone="violet" />
          </Section>
          <Section title="Today's attendance" icon={<Clock className="h-4 w-4" />}>
            <Stat label="Present" value={s.today.present} icon={<UserCheck className="h-5 w-5" />} tone="green" />
            <Stat label="Absent" value={s.today.absent} sub={s.today.not_arrived ? `${s.today.not_arrived} not arrived yet` : undefined} icon={<UserX className="h-5 w-5" />} tone="red" />
            <Stat label="On leave" value={s.today.on_leave} icon={<CalendarOff className="h-5 w-5" />} tone="blue" />
            <Stat label="Half day" value={s.today.half_day} icon={<TimerReset className="h-5 w-5" />} tone="amber" />
            <Stat label="Late" value={s.today.late} icon={<AlarmClock className="h-5 w-5" />} tone="amber" />
            <Stat label="Early checkout" value={s.today.early_checkout} icon={<LogOut className="h-5 w-5" />} tone="amber" />
            <Stat label="Currently working" value={s.today.currently_working} icon={<Briefcase className="h-5 w-5" />} tone="green" />
            <Stat label="Holiday / week-off" value={s.today.holiday_or_weekoff} icon={<Clock className="h-5 w-5" />} />
          </Section>

          <div className="grid gap-4 lg:grid-cols-3">
            <Card className="p-4 sm:p-5">
              <div className="mb-3 text-sm font-semibold text-slate-800">Working hours (today)</div>
              <Row k="Total hours" v={`${s.hours.total_hours} h`} />
              <Row k="Average / employee" v={`${s.hours.average_hours} h`} />
              <Row k="Overtime" v={`${s.hours.overtime_hours} h`} />
            </Card>
            <Card className="p-4 sm:p-5 lg:col-span-2">
              <div className="mb-4 flex items-center justify-between gap-3">
                <div className="text-sm font-semibold text-slate-800">Payroll {per ? `· ${monthName(per.month)} ${per.year}` : ""}</div>
                {per && <StatusBadge s={per.status} />}
              </div>
              {pay?.totals ? (
                <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 xl:grid-cols-5">
                  <Mini k="Gross" v={inrShort(pay.totals.gross)} />
                  <Mini k="Deductions" v={inrShort(pay.totals.deductions)} />
                  <Mini k="Net" v={inrShort(pay.totals.net)} />
                  <Mini k="Pending" v={inrShort(pay.pending_net)} />
                  <Mini k="Processed" v={inrShort(pay.processed_net)} />
                </div>
              ) : <div className="rounded-xl bg-surface-50 p-4 text-sm text-slate-500">No payroll period yet. Open Payroll to create one.</div>}
            </Card>
          </div>

          <div className="grid gap-4 xl:grid-cols-2">
            <Card>
              <CardHeader title="Attendance overview" sub="Last 14 days" />
              <ChartFrame>
                {trend.length ? <ResponsiveContainer>
                  <BarChart data={trend} margin={{ top: 8, right: 8, left: -16, bottom: 0 }}>
                    <CartesianGrid stroke="var(--subtle-border)" strokeDasharray="4 5" vertical={false} />
                    <XAxis dataKey="day" tickLine={false} axisLine={false} fontSize={11} tick={{ fill: "var(--muted)" }} />
                    <YAxis tickLine={false} axisLine={false} fontSize={11} allowDecimals={false} tick={{ fill: "var(--muted)" }} />
                    <Tooltip contentStyle={tooltipStyle} cursor={{ fill: "var(--hover-surface)", opacity: 0.7 }} />
                    <Legend wrapperStyle={legendStyle} />
                    <Bar dataKey="present" stackId="attendance" fill={CHART_COLORS.success} name="Present" radius={[4, 4, 0, 0]} animationDuration={500} />
                    <Bar dataKey="on_leave" stackId="attendance" fill={CHART_COLORS.sky} name="On leave" animationDuration={500} />
                    <Bar dataKey="absent" stackId="attendance" fill={CHART_COLORS.danger} name="Absent" radius={[4, 4, 0, 0]} animationDuration={500} />
                  </BarChart>
                </ResponsiveContainer> : <Empty text="No attendance trend available" />}
              </ChartFrame>
            </Card>

            <Card>
              <CardHeader title="Working hours & overtime" sub="Last 14 days" />
              <ChartFrame>
                {trend.length ? <ResponsiveContainer>
                  <ComposedChart data={trend} margin={{ top: 8, right: 8, left: -16, bottom: 0 }}>
                    <defs>
                      <linearGradient id="hoursArea" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0%" stopColor={CHART_COLORS.violet} stopOpacity={0.24} />
                        <stop offset="95%" stopColor={CHART_COLORS.violet} stopOpacity={0.02} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid stroke="var(--subtle-border)" strokeDasharray="4 5" vertical={false} />
                    <XAxis dataKey="day" tickLine={false} axisLine={false} fontSize={11} tick={{ fill: "var(--muted)" }} />
                    <YAxis tickLine={false} axisLine={false} fontSize={11} tick={{ fill: "var(--muted)" }} />
                    <Tooltip contentStyle={tooltipStyle} cursor={{ fill: "var(--hover-surface)", opacity: 0.7 }} />
                    <Legend wrapperStyle={legendStyle} />
                    <Area type="monotone" dataKey="hours" fill="url(#hoursArea)" stroke={CHART_COLORS.violet} strokeWidth={2} name="Hours" animationDuration={600} />
                    <Line type="monotone" dataKey="overtime" stroke={CHART_COLORS.sky} strokeWidth={2} name="Overtime h" dot={false} animationDuration={600} />
                    <Line type="monotone" dataKey="late" stroke={CHART_COLORS.amber} strokeWidth={2} name="Late (count)" dot={false} animationDuration={600} />
                  </ComposedChart>
                </ResponsiveContainer> : <Empty text="No working-hours trend available" />}
              </ChartFrame>
            </Card>

            <Card>
              <CardHeader title="Monthly payroll trend" sub="Gross vs net by period" />
              <ChartFrame>
                {pay?.trend?.length ? <ResponsiveContainer>
                  <BarChart data={pay.trend} margin={{ top: 8, right: 8, left: 0, bottom: 0 }}>
                    <CartesianGrid stroke="var(--subtle-border)" strokeDasharray="4 5" vertical={false} />
                    <XAxis dataKey="period" tickLine={false} axisLine={false} fontSize={11} tick={{ fill: "var(--muted)" }} />
                    <YAxis tickLine={false} axisLine={false} fontSize={11} tickFormatter={(value) => inrShort(value)} tick={{ fill: "var(--muted)" }} />
                    <Tooltip contentStyle={tooltipStyle} formatter={(value: any) => inrShort(Number(value))} cursor={{ fill: "var(--hover-surface)", opacity: 0.7 }} />
                    <Legend wrapperStyle={legendStyle} />
                    <Bar dataKey="gross" fill={CHART_COLORS.violet} name="Gross" radius={[6, 6, 0, 0]} animationDuration={500} />
                    <Bar dataKey="net" fill={CHART_COLORS.teal} name="Net" radius={[6, 6, 0, 0]} animationDuration={500} />
                  </BarChart>
                </ResponsiveContainer> : <Empty text="No payroll data yet" />}
              </ChartFrame>
            </Card>

            <Card>
              <CardHeader title="Office distribution" sub="Present today vs employees" />
              <ChartFrame>
                {s.offices.length ? <ResponsiveContainer>
                  <BarChart data={s.offices} margin={{ top: 8, right: 8, left: -16, bottom: 0 }}>
                    <CartesianGrid stroke="var(--subtle-border)" strokeDasharray="4 5" vertical={false} />
                    <XAxis dataKey="office" tickLine={false} axisLine={false} fontSize={11} tick={{ fill: "var(--muted)" }} />
                    <YAxis tickLine={false} axisLine={false} fontSize={11} allowDecimals={false} tick={{ fill: "var(--muted)" }} />
                    <Tooltip contentStyle={tooltipStyle} cursor={{ fill: "var(--hover-surface)", opacity: 0.7 }} />
                    <Legend wrapperStyle={legendStyle} />
                    <Bar dataKey="employees" fill={CHART_COLORS.slate} name="Employees" radius={[6, 6, 0, 0]} />
                    <Bar dataKey="present" fill={CHART_COLORS.success} name="Present" radius={[6, 6, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer> : <Empty text="No office distribution available" />}
              </ChartFrame>
            </Card>
          </div>

          <div className="grid gap-4 xl:grid-cols-3">
            <Card className="xl:col-span-2">
              <CardHeader title="Today's attendance" sub={daily.data ? `${daily.data.total} employees` : undefined} />
              {daily.error && <ErrorNote text={daily.error} className="m-4" />}
              {daily.loading && !daily.data && <div className="space-y-3 p-4"><Skeleton className="h-8 w-full" /><Skeleton className="h-8 w-full" /><Skeleton className="h-8 w-full" /></div>}
              {daily.data && <div className="overflow-x-auto">
                <table className="tbl tbl-cards">
                  <thead><tr><th>Employee</th><th>Office</th><th>In</th><th>Out</th><th>Hours</th><th>Status</th></tr></thead>
                  <tbody>{(daily.data.rows || []).map((row: any) => (
                    <tr key={row.employee_code}>
                      <td data-label="Employee"><span className="font-medium text-slate-800">{row.name}</span> <span className="text-xs text-slate-600">#{row.employee_code}</span></td>
                      <td data-label="Office">{row.office}</td><td data-label="In">{fmtTime(row.check_in)}</td>
                      <td data-label="Out">{row.currently_working ? <span className="font-medium text-emerald-800">Working</span> : fmtTime(row.check_out)}</td>
                      <td data-label="Hours">{fmtHM(row.worked_minutes)}</td><td data-label="Status"><StatusBadge s={row.status} /></td>
                    </tr>
                  ))}</tbody>
                </table>
                {!daily.data.rows?.length && <Empty text="No employees to show" />}
              </div>}
            </Card>

            <div className="space-y-4">
              <Card>
                <CardHeader title="AI recognition today" />
                <div className="space-y-1 px-5 py-3 text-sm">
                  <Row k="Recognized" v={s.ai.recognized} />
                  <Row k="Unknown faces" v={s.ai.unknown} />
                  <Row k="Spoof rejected" v={s.ai.liveness_rejected} />
                  <Row k="Low quality" v={s.ai.low_quality} />
                  <Row k="Avg confidence" v={s.ai.average_confidence ?? "—"} />
                </div>
              </Card>
              <Card>
                <CardHeader title="Pending leave approvals" sub="Requests awaiting a decision" right={<button type="button" className="btn-soft btn-sm" onClick={() => go("leave")}>Review</button>} />
                {pendingLeaves.error && <ErrorNote text={pendingLeaves.error} className="mx-4 mt-4" />}
                {pendingLeaves.loading && !pendingLeaves.data && <div className="space-y-3 p-4"><Skeleton className="h-8 w-full" /><Skeleton className="h-8 w-3/4" /></div>}
                <ul className="divide-y divide-white/10">
                  {(pendingLeaves.data || []).slice(0, 4).map((leave) => <li key={leave.id} className="flex items-center justify-between gap-3 px-4 py-3 text-sm">
                    <span className="min-w-0"><span className="block truncate font-medium text-slate-700">{leave.name}</span><span className="text-xs text-slate-500">{leave.leave_type_name} · {leave.start_date}</span></span>
                    <span className="shrink-0 text-xs tabular-nums text-text-muted">{leave.days}d</span>
                  </li>)}
                  {!pendingLeaves.loading && !pendingLeaves.error && !pendingLeaves.data?.length && <li><Empty text="No leave requests waiting for approval" /></li>}
                </ul>
              </Card>
              <Card>
                <CardHeader title="Recent activity" sub="Latest system events" />
                {events.error && <ErrorNote text={events.error} className="mx-4 mt-4" />}
                {events.loading && !events.data && <div className="space-y-3 p-4"><Skeleton className="h-8 w-full" /><Skeleton className="h-8 w-full" /></div>}
                <ul className="divide-y divide-brand-50">
                  {(events.data || []).map((event) => {
                    const label = String(event.type || "Activity").replace(/_/g, " ").toLowerCase();
                    const isRecent = isWithinMinute(event.created_at);
                    const name = event.employee_id ? `Employee ${event.employee_id}` : label;
                    return                     <li key={event.id} className="flex items-center gap-3 px-4 py-3 transition-colors hover:bg-brand-50">
                      <Avatar name={name} className="h-9 w-9 text-xs" />
                      <div className="min-w-0 flex-1">
                        <div className="truncate text-sm font-medium capitalize text-slate-700">{label}</div>
                        <div className="mt-0.5 flex items-center gap-1.5 text-xs text-slate-400">
                          {isRecent && <><span className="h-1.5 w-1.5 animate-pulse rounded-full bg-success" />Live · </>}
                          {event.employee_id ? `Employee ${event.employee_id} · ` : ""}{relativeTime(event.created_at)}
                        </div>
                      </div>
                      <Activity className="h-4 w-4 shrink-0 text-brand-300" />
                    </li>;
                  })}
                  {!events.loading && !events.error && !events.data?.length && <li><Empty text="No activity yet" /></li>}
                </ul>
              </Card>
            </div>
          </div>
        </>
      )}
    </div>
  );
}

function Section({ title, icon, children }: { title: string; icon: React.ReactNode; children: React.ReactNode }) {
  return <section>
    <SectionBar icon={icon} title={title} />
    <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-4">{children}</div>
  </section>;
}

const Row = ({ k, v }: { k: string; v: any }) => (
  <div className="flex justify-between gap-4 border-b border-white/10 py-2 text-sm last:border-0">
    <span className="text-slate-500">{k}</span><span className="text-right font-semibold tabular-nums text-slate-800">{v}</span>
  </div>
);

const Mini = ({ k, v }: { k: string; v: any }) => (
  <div className="rounded-xl border border-white/10 bg-surface-50 p-3">
    <div className="text-lg font-bold tabular-nums text-slate-800">{v}</div><div className="mt-0.5 text-xs text-slate-500">{k}</div>
  </div>
);

function ChartFrame({ children }: { children: React.ReactNode }) {
  return <div className="h-[270px] min-w-0 p-3 sm:p-4">{children}</div>;
}

const tooltipStyle = {
  border: "1px solid var(--card-border)",
  borderRadius: "14px",
  backgroundColor: "var(--surface)",
  color: "var(--ink)",
  boxShadow: "0 8px 24px -8px rgba(76,48,170,.14)",
  fontSize: "12px",
};
const legendStyle = { paddingTop: "10px", fontSize: "11px", lineHeight: "18px" };

function isWithinMinute(timestamp?: string | null) {
  const parsed = timestamp ? Date.parse(timestamp) : Number.NaN;
  return Number.isFinite(parsed) && Date.now() - parsed < 60_000 && Date.now() >= parsed;
}

function relativeTime(timestamp?: string | null) {
  const parsed = timestamp ? Date.parse(timestamp) : Number.NaN;
  if (!Number.isFinite(parsed)) return "Time unavailable";
  const elapsed = Math.max(0, Date.now() - parsed);
  if (elapsed < 60_000) return "Just now";
  if (elapsed < 3_600_000) return `${Math.floor(elapsed / 60_000)}m ago`;
  if (elapsed < 86_400_000) return `${Math.floor(elapsed / 3_600_000)}h ago`;
  return `${Math.floor(elapsed / 86_400_000)}d ago`;
}
