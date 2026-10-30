import { FormEvent, useEffect, useState } from "react";
import { ArrowLeft, Check, Eye, EyeOff, KeyRound, Loader2, Mail, ScanFace, ShieldCheck } from "lucide-react";
import { UserRole } from "./Layout";
import LoginMascot, { LoginMascotState } from "./LoginMascot";
import Logo from "./Logo";
import { Card, cx, ErrorNote } from "./ui";

export function Splash({ onDone }: { onDone: () => void }) {
  useEffect(() => {
    sessionStorage.setItem("veridant-splash-seen", "true");
    const delay = window.matchMedia("(prefers-reduced-motion: reduce)").matches ? 0 : 2000;
    const timer = window.setTimeout(onDone, delay);
    return () => window.clearTimeout(timer);
  }, [onDone]);

  return <main className="veridant-splash grid min-h-screen place-items-center overflow-hidden px-6 text-center text-white">
    <div className="flex flex-col items-center">
      <div className="veridant-mark-enter"><Logo size={92} /></div>
      <div className="veridant-wordmark mt-5 font-heading text-3xl font-semibold tracking-[.12em]">Veridant</div>
      <p className="mt-2 text-sm text-white">Face attendance &amp; payroll</p>
      <div className="mt-9 h-1 w-48 overflow-hidden rounded-full bg-white/25"><div className="veridant-splash-progress h-full rounded-full bg-white/90" /></div>
    </div>
  </main>;
}

export function RoleSelect({ onSelect, onBack }: { onSelect: (role: UserRole) => void; onBack?: () => void }) {
  const [selected, setSelected] = useState<UserRole | null>(null);
  const choose = (role: UserRole) => {
    if (selected) return;
    setSelected(role);
    const delay = window.matchMedia("(prefers-reduced-motion: reduce)").matches ? 0 : 180;
    window.setTimeout(() => onSelect(role), delay);
  };

  return <main className="relative grid min-h-screen place-items-center px-4 py-12 text-ink sm:px-6">
    {onBack && <button type="button" aria-label="Go back" className="btn-ghost absolute left-4 top-4 !h-11 !w-11 !p-0 sm:left-6 sm:top-6" onClick={onBack}><ArrowLeft className="h-5 w-5" /></button>}
    <div className="w-full max-w-2xl">
      <div className="mb-7 flex justify-center"><Logo size={44} withWordmark /></div>
      <h1 className="mt-2 text-center font-heading text-3xl font-semibold">Who are you?</h1>
      <p className="mt-2 text-center text-sm text-slate-700">Choose the workspace that fits your day.</p>
      <div className="mt-8 grid gap-4 sm:grid-cols-2">
        <button type="button" aria-pressed={selected === "admin"} disabled={!!selected} className={cx("card-interactive min-h-48 p-6 text-left text-ink", selected === "admin" && "border-violet ring-2 ring-violet/30")} onClick={() => choose("admin")}>
          <span className="relative grid h-12 w-12 place-items-center rounded-xl bg-brand-100 text-brand-700"><ShieldCheck className="h-6 w-6" />{selected === "admin" && <Check className="absolute -right-1 -top-1 h-5 w-5 rounded-full bg-violet p-0.5 text-white" />}</span>
          <h2 className="mt-5 font-heading text-lg font-semibold">Admin</h2>
          <p className="mt-2 text-sm text-slate-700">Manage people, payroll and leave.</p>
        </button>
        <button type="button" aria-pressed={selected === "employee"} disabled={!!selected} className={cx("card-interactive min-h-48 p-6 text-left text-ink", selected === "employee" && "border-violet ring-2 ring-violet/30")} onClick={() => choose("employee")}>
          <span className="relative grid h-12 w-12 place-items-center rounded-xl bg-brand-100 text-brand-700"><ScanFace className="h-6 w-6" />{selected === "employee" && <Check className="absolute -right-1 -top-1 h-5 w-5 rounded-full bg-violet p-0.5 text-white" />}</span>
          <h2 className="mt-5 font-heading text-lg font-semibold">Employee</h2>
          <p className="mt-2 text-sm text-slate-700">Scan your face to mark attendance.</p>
        </button>
      </div>
      <p className="mt-6 text-center text-xs leading-5 text-amber-900">Role selection is a local demo gate only; it does not authenticate your account.</p>
    </div>
  </main>;
}

export function Login({ role, onChangeRole, onLogin, onBack }: {
  role: UserRole; onChangeRole: () => void; onLogin: (email: string, remember: boolean) => void; onBack: () => void;
}) {
  const [email, setEmail] = useState(() => window.localStorage.getItem("veridant-demo-email") || "");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [remember, setRemember] = useState(true);
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  const [mascotState, setMascotState] = useState<LoginMascotState>("idle");
  const [forgotHint, setForgotHint] = useState(false);

  const clearError = () => {
    if (error) setError("");
    if (mascotState === "error") setMascotState("idle");
  };

  const submit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setError("");
    const normalizedEmail = email.trim();
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalizedEmail) || !password) {
      setError("Check your email and password and try again.");
      setMascotState("error");
      return;
    }
    setBusy(true);
    setMascotState("success");
    window.setTimeout(() => {
      setBusy(false);
      onLogin(normalizedEmail, remember);
    }, 500);
  };

  return <main className="min-h-screen bg-bg-deep text-ink lg:grid lg:grid-cols-[.9fr_1.1fr]">
    <section className="login-brand-panel relative hidden min-h-screen flex-col justify-between overflow-hidden p-10 lg:flex xl:p-16">
      <Logo size={48} withWordmark className="[&_span]:text-white" />
      <div className="relative z-10 mx-auto w-full max-w-lg text-center">
        <h1 className="font-heading text-3xl font-semibold leading-tight xl:text-4xl">Attendance and payroll, simplified.</h1>
        <p className="mt-4 text-sm leading-6 text-white/90">A clear view of attendance and payroll, designed for every workday.</p>
        <div className="mt-8"><LoginMascot state={mascotState} showPassword={showPassword} /></div>
      </div>
      <p className="text-xs text-white/90">Face attendance &amp; payroll</p>
    </section>
    <section className="min-h-screen">
      <div className="login-mobile-header rounded-b-[2.5rem] px-6 pb-16 pt-7 lg:hidden">
        <button type="button" aria-label="Go back" onClick={onBack} className="mb-6 grid h-11 w-11 place-items-center rounded-xl text-white hover:bg-brand-600"><ArrowLeft className="h-5 w-5" /></button>
        <Logo size={42} withWordmark className="[&_span]:text-white" />
        <h1 className="mt-5 max-w-sm font-heading text-2xl font-semibold leading-tight">Attendance and payroll, simplified.</h1>
        <div className="mx-auto mt-1 h-32 w-36"><LoginMascot state={mascotState} showPassword={showPassword} /></div>
      </div>
      <div className="-mt-10 flex min-h-[calc(100vh-4rem)] items-start justify-center px-4 pb-8 lg:mt-0 lg:min-h-screen lg:items-center lg:px-8">
        <div className="w-full max-w-md">
          <Card className={cx("p-6 sm:p-8", error && "login-card-error")}>
            <div><h2 className="font-heading text-2xl font-semibold">Log in</h2><p className="mt-1 text-sm text-slate-700">Welcome back. Enter your details to continue.</p></div>
            <button type="button" onClick={onChangeRole} className="mt-5 inline-flex min-h-11 items-center gap-2 rounded-full border border-brand-200 bg-brand-50 px-4 text-sm font-medium text-brand-700">
              {role === "admin" ? <ShieldCheck className="h-4 w-4" /> : <ScanFace className="h-4 w-4" />}
              {role === "admin" ? "Admin" : "Employee"} · Change role
            </button>
            <form className="mt-6 space-y-4" onSubmit={submit} noValidate>
              <label className="block"><span className="label">Email</span>
                <span className="relative block"><Mail className="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-600" />
                  <input autoComplete="email" className="input !pl-11" type="email" value={email}
                    onFocus={() => setMascotState(error ? "error" : "email")} onBlur={() => setMascotState(error ? "error" : "idle")}
                    onChange={(event) => { setEmail(event.target.value); clearError(); }} placeholder="you@company.com" /></span>
              </label>
              <label className="block"><span className="label">Password</span>
                <span className="relative block"><KeyRound className="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-600" />
                  <input autoComplete="current-password" className="input !pl-11 !pr-12" type={showPassword ? "text" : "password"} value={password}
                    onFocus={() => setMascotState(error ? "error" : "password")} onBlur={() => setMascotState(error ? "error" : "idle")}
                    onChange={(event) => { setPassword(event.target.value); clearError(); }} placeholder="Enter your password" />
                  <button type="button" aria-label={showPassword ? "Hide password" : "Show password"} className="absolute right-1 top-1/2 grid h-10 w-10 -translate-y-1/2 place-items-center rounded-lg text-slate-600 hover:bg-brand-50 hover:text-brand-700" onClick={() => setShowPassword((shown) => !shown)}>
                    {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button></span>
              </label>
              <div className="flex flex-wrap items-center justify-between gap-2 text-xs">
                <label className="flex min-h-11 items-center gap-2 text-slate-700"><input type="checkbox" checked={remember} onChange={(event) => setRemember(event.target.checked)} />Remember me</label>
                <button type="button" className="min-h-11 text-brand-700 underline-offset-2 hover:underline" onClick={() => setForgotHint((shown) => !shown)}>Forgot password?</button>
              </div>
              {forgotHint && <p className="text-xs text-slate-700">Ask your administrator to reset your password.</p>}
              <ErrorNote text={error} />
              <button type="submit" className="btn-primary w-full" disabled={busy}>
                {busy ? <><Loader2 className="h-4 w-4 animate-spin" />Opening workspace...</> : "Log in"}
              </button>
            </form>
            <p className="mt-5 rounded-xl border border-amber-200 bg-amber-50 p-3 text-xs leading-5 text-amber-900">
              Demo role gate only: no login endpoint exists in this app. Credentials are not sent to a server. Connect real authentication before deployment.
            </p>
          </Card>
        </div>
      </div>
    </section>
  </main>;
}
