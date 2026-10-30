import {
  Children, createContext, isValidElement, KeyboardEvent as ReactKeyboardEvent, ReactElement, ReactNode,
  useCallback, useContext, useEffect, useId, useRef, useState,
} from "react";
import { AlertTriangle, Check, ChevronDown, Inbox, Loader2, X } from "lucide-react";

export const cx = (...a: (string | false | undefined | null)[]) => a.filter(Boolean).join(" ");

export function Card({ children, className }: { children: ReactNode; className?: string }) {
  return <div className={cx("card spot relative min-w-0", className)}>{children}</div>;
}
export function CardHeader({ title, sub, right }: { title: ReactNode; sub?: ReactNode; right?: ReactNode }) {
  return (
    <div className="flex items-start justify-between gap-3 border-b border-brand-200 px-5 py-4">
      <div className="min-w-0"><h3 className="font-heading text-base font-semibold text-ink">{title}</h3>{sub && <p className="mt-0.5 text-xs text-slate-600">{sub}</p>}</div>
      {right}
    </div>
  );
}
export function PageHeader({ title, sub, right }: { title: string; sub?: ReactNode; right?: ReactNode }) {
  return (
    <div className="mb-5 flex flex-wrap items-end justify-between gap-3">
      <div><h1 className="font-heading text-2xl font-semibold tracking-tight text-ink">{title}</h1>{sub && <p className="mt-1 text-sm text-slate-600">{sub}</p>}</div>
      <div className="flex flex-wrap items-center gap-2">{right}</div>
    </div>
  );
}

const TONES: Record<string, string> = {
  slate: "bg-slate-100 text-slate-700 ring-1 ring-inset ring-slate-200",
  green: "bg-emerald-50 text-emerald-800 ring-1 ring-inset ring-emerald-200",
  red: "bg-rose-50 text-rose-800 ring-1 ring-inset ring-rose-200",
  amber: "bg-amber-50 text-amber-900 ring-1 ring-inset ring-amber-200",
  blue: "bg-blue-50 text-blue-800 ring-1 ring-inset ring-blue-200",
  violet: "bg-brand-100 text-brand-700 ring-1 ring-inset ring-brand-200",
};
export function Badge({ tone = "slate", children }: { tone?: keyof typeof TONES | string; children: ReactNode }) {
  return <span className={cx("inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold", TONES[tone] || TONES.slate)}>{children}</span>;
}
export const STATUS_TONE: Record<string, string> = {
  PRESENT: "green", LATE: "amber", HALF_DAY: "amber", ABSENT: "red", ON_LEAVE: "blue", HOLIDAY: "violet", WEEK_OFF: "slate",
  NOT_ARRIVED: "slate", FUTURE: "slate", DRAFT: "slate", CALCULATED: "blue", APPROVED: "violet", PROCESSED: "amber", PAID: "green",
  PENDING: "amber", REJECTED: "red", CANCELLED: "slate",
};
export const StatusBadge = ({ s }: { s: string }) => {
  const label = s.toLowerCase().replace(/_/g, " ");
  return <Badge tone={STATUS_TONE[s] || "slate"}>{label.charAt(0).toUpperCase() + label.slice(1)}</Badge>;
};

export function Stat({ label, value, sub, icon, tone = "slate", trend }: { label: string; value: ReactNode; sub?: ReactNode; icon?: ReactNode; tone?: string; trend?: ReactNode }) {
  const ring: Record<string, string> = {
    slate: "bg-slate-100 text-slate-700", green: "bg-emerald-50 text-emerald-800",
    red: "bg-rose-50 text-rose-800", amber: "bg-amber-50 text-amber-900",
    blue: "bg-blue-50 text-blue-800", violet: "bg-brand-100 text-brand-700",
  };
  return (
    <div className="card spot relative flex min-w-0 items-center gap-3 p-4 transition-all duration-200 hover:-translate-y-0.5 hover:shadow-soft">
      {icon && <div className={cx("grid h-11 w-11 shrink-0 place-items-center rounded-xl", ring[tone] || ring.slate)}>{icon}</div>}
      <div className="min-w-0 flex-1"><div className="truncate font-heading text-xl font-bold tabular-nums text-ink">{typeof value === "number" ? <CountUp value={value} /> : value}</div>
        <div className="truncate text-xs font-medium text-slate-700">{label}</div>{(sub || trend) && <div className="mt-1 text-[11px] text-slate-600">{trend || sub}</div>}</div>
    </div>
  );
}

function CountUp({ value }: { value: number }) {
  const [display, setDisplay] = useState(0);
  const current = useRef(0);
  useEffect(() => {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      current.current = value;
      setDisplay(value);
      return;
    }
    const from = current.current;
    const startedAt = performance.now();
    let frame = 0;
    const tick = (now: number) => {
      const progress = Math.min(1, (now - startedAt) / 500);
      const next = from + (value - from) * progress;
      current.current = next;
      setDisplay(next);
      if (progress < 1) frame = window.requestAnimationFrame(tick);
      else current.current = value;
    };
    frame = window.requestAnimationFrame(tick);
    return () => window.cancelAnimationFrame(frame);
  }, [value]);
  return <>{new Intl.NumberFormat(undefined, { maximumFractionDigits: 2 }).format(display)}</>;
}

export const Spinner = () => <Loader2 className="h-4 w-4 animate-spin" />;
export function Skeleton({ className }: { className?: string }) {
  return <div aria-hidden="true" className={cx("relative overflow-hidden rounded-xl bg-brand-100 before:absolute before:inset-0 before:-translate-x-full before:animate-shimmer before:bg-gradient-to-r before:from-transparent before:via-white before:to-transparent", className)} />;
}
export function Loading({ text = "Loading..." }: { text?: string }) {
  return <div role="status" aria-label={text} className="space-y-4 py-3">
    <span className="sr-only">{text}</span>
    <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">{Array.from({ length: 4 }, (_, i) => <div key={i} className="card space-y-3 p-4"><Skeleton className="h-10 w-10 rounded-xl" /><Skeleton className="h-6 w-20" /><Skeleton className="h-3 w-28" /></div>)}</div>
    <div className="grid gap-4 md:grid-cols-2">{Array.from({ length: 2 }, (_, i) => <Skeleton key={i} className="h-56 rounded-2xl" />)}</div>
  </div>;
}
export function Empty({ text = "No data available" }: { text?: string }) {
  return <div className="flex flex-col items-center gap-3 p-8 text-center text-sm text-slate-600">
    <span aria-hidden="true" className="grid h-14 w-14 place-items-center rounded-2xl border border-brand-200 bg-brand-50 text-brand-700"><Inbox className="h-6 w-6" /></span>
    <span>{text}</span>
  </div>;
}
export function ErrorNote({ text, className }: { text?: string; className?: string }) {
  if (!text) return null;
  return <div role="alert" className={cx("flex items-start gap-2 rounded-2xl border border-danger/30 bg-danger/10 p-3 text-sm text-danger", className)}><AlertTriangle className="mt-0.5 h-4 w-4 shrink-0" />{text}</div>;
}
export function Note({ children, tone = "blue" }: { children: ReactNode; tone?: "blue" | "amber" | "green" }) {
  const t = { blue: "border-blue-200 bg-blue-50 text-blue-900", amber: "border-amber-200 bg-amber-50 text-amber-900", green: "border-emerald-200 bg-emerald-50 text-emerald-900" }[tone];
  return <div className={cx("flex items-start gap-2 rounded-2xl border p-4 text-sm", t)}>{tone === "amber" && <AlertTriangle className="mt-0.5 h-4 w-4 shrink-0" />}{children}</div>;
}

export function Field({ label, children, className }: { label: string; children: ReactNode; className?: string }) {
  return <label className={cx("block", className)}><span className="label">{label}</span>{children}</label>;
}

export function Modal({ title, onClose, children, wide }: { title: string; onClose: () => void; children: ReactNode; wide?: boolean }) {
  useEffect(() => { const k = (e: KeyboardEvent) => e.key === "Escape" && onClose(); window.addEventListener("keydown", k); return () => window.removeEventListener("keydown", k); }, [onClose]);
  return (
    <div className="fixed inset-0 z-50 grid items-end bg-ink/25 p-0 backdrop-blur-sm sm:place-items-center sm:p-4" onMouseDown={onClose}>
      <div role="dialog" aria-modal="true" aria-label={title} className={cx("card max-h-[92vh] w-full animate-modal-enter overflow-auto rounded-b-none rounded-t-3xl sm:rounded-3xl", wide ? "sm:max-w-3xl" : "sm:max-w-md")} onMouseDown={(e) => e.stopPropagation()}>
        <div className="sticky top-0 flex items-center justify-between border-b border-brand-200 bg-white px-5 py-4"><h3 className="font-heading font-semibold text-ink">{title}</h3>
          <button aria-label="Close dialog" onClick={onClose} className="btn-ghost btn-sm"><X className="h-4 w-4" /></button></div>
        <div className="p-4">{children}</div>
      </div>
    </div>
  );
}

export function Drawer({ title, onClose, children }: { title: string; onClose: () => void; children: ReactNode }) {
  useEffect(() => { const k = (e: KeyboardEvent) => e.key === "Escape" && onClose(); window.addEventListener("keydown", k); return () => window.removeEventListener("keydown", k); }, [onClose]);
  return (
    <div className="fixed inset-0 z-40 bg-ink/25 backdrop-blur-sm" onMouseDown={onClose}>
      <div role="dialog" aria-modal="true" aria-label={title} className="absolute inset-x-0 bottom-0 max-h-[88vh] w-full overflow-auto rounded-t-3xl border border-brand-200 bg-white shadow-xl md:inset-y-0 md:left-auto md:right-0 md:h-full md:max-h-full md:max-w-2xl md:rounded-none md:rounded-l-2xl" onMouseDown={(e) => e.stopPropagation()}>
        <div className="sticky top-0 z-10 flex items-center justify-between border-b border-brand-200 bg-white px-5 py-3">
          <h2 className="font-semibold text-ink">{title}</h2><button aria-label="Close drawer" onClick={onClose} className="btn-ghost btn-sm"><X className="h-5 w-5" /></button></div>
        <div className="space-y-4 p-5">{children}</div>
      </div>
    </div>
  );
}

type ToastItem = { id: number; message: string; tone: "success" | "error" };
const ToastContext = createContext<{ success: (message: string) => void; error: (message: string) => void } | null>(null);
export function Toast({ message, tone, onDismiss }: { message: string; tone: "success" | "error"; onDismiss: () => void }) {
  const success = tone === "success";
  return <div role={success ? "status" : "alert"} className={cx("flex items-start gap-3 rounded-xl border bg-white p-3 text-sm shadow-soft", success ? "border-emerald-200 text-emerald-900" : "border-rose-200 text-rose-900")}>
    {success ? <Check className="mt-0.5 h-4 w-4 shrink-0 text-emerald-600" /> : <AlertTriangle className="mt-0.5 h-4 w-4 shrink-0 text-rose-600" />}
    <span className="flex-1">{message}</span><button aria-label="Dismiss notification" onClick={onDismiss} className="rounded-md p-2 text-slate-600 hover:bg-slate-100"><X className="h-4 w-4" /></button>
  </div>;
}
export function ToastProvider({ children }: { children: ReactNode }) {
  const [items, setItems] = useState<ToastItem[]>([]);
  const timers = useRef(new Map<number, number>());
  const dismiss = useCallback((id: number) => {
    const timer = timers.current.get(id);
    if (timer !== undefined) window.clearTimeout(timer);
    timers.current.delete(id);
    setItems((current) => current.filter((item) => item.id !== id));
  }, []);
  const push = useCallback((message: string, tone: ToastItem["tone"]) => {
    const id = Date.now() + Math.random();
    setItems((current) => [...current, { id, message, tone }]);
    timers.current.set(id, window.setTimeout(() => dismiss(id), 4500));
  }, [dismiss]);
  useEffect(() => () => timers.current.forEach((timer) => window.clearTimeout(timer)), []);
  const value = {
    success: (message: string) => push(message, "success"),
    error: (message: string) => push(message, "error"),
  };
  return <ToastContext.Provider value={value}>{children}
    <div aria-label="Notifications" className="pointer-events-none fixed right-4 top-4 z-[70] flex w-[min(24rem,calc(100vw-2rem))] flex-col gap-2">
      {items.map((item) => <div key={item.id} className="pointer-events-auto"><Toast message={item.message} tone={item.tone} onDismiss={() => dismiss(item.id)} /></div>)}
    </div>
  </ToastContext.Provider>;
}
export function useToast() {
  const context = useContext(ToastContext);
  if (!context) throw new Error("useToast must be used within ToastProvider");
  return context;
}

export function Tabs({ items, value, onChange }: { items: { id: string; label: ReactNode }[]; value: string; onChange: (value: string) => void }) {
  return <div role="tablist" className="flex max-w-full gap-1 overflow-x-auto rounded-xl border border-brand-200 bg-brand-50 p-1">
    {items.map((item) => <button key={item.id} type="button" role="tab" aria-selected={value === item.id} onClick={() => onChange(item.id)}
      className={cx("min-h-10 shrink-0 rounded-lg px-4 py-2 text-sm font-medium", value === item.id ? "bg-white text-brand-700 shadow-sm" : "text-slate-700 hover:text-brand-700")}>{item.label}</button>)}
  </div>;
}

function nameColor(name: string) {
  const colors = ["bg-brand-100 text-brand-700", "bg-blue-50 text-blue-800", "bg-emerald-50 text-emerald-800", "bg-amber-50 text-amber-900", "bg-rose-50 text-rose-800"];
  let hash = 0;
  for (let i = 0; i < name.length; i += 1) hash = (hash * 31 + name.charCodeAt(i)) | 0;
  return colors[Math.abs(hash) % colors.length];
}
export function Avatar({ name, src, className }: { name: string; src?: string | null; className?: string }) {
  const initials = name.trim().split(/\s+/).slice(0, 2).map((part) => part[0]?.toUpperCase()).join("") || "?";
  return src
    ? <img src={src} alt={name} className={cx("h-10 w-10 rounded-full object-cover", className)} />
    : <span aria-label={name} className={cx("inline-grid h-10 w-10 shrink-0 place-items-center rounded-full text-sm font-bold", nameColor(name), className)}>{initials}</span>;
}

export function ConfirmDialog({ title, message, confirmLabel = "Confirm", onConfirm, onClose, tone = "danger" }: {
  title: string; message: ReactNode; confirmLabel?: string; onConfirm: () => void; onClose: () => void; tone?: "danger" | "primary";
}) {
  return <Modal title={title} onClose={onClose}>
    <p className="text-sm leading-6 text-slate-700">{message}</p>
    <div className="mt-5 flex justify-end gap-2">
      <button type="button" className="btn-ghost" onClick={onClose}>Cancel</button>
      <button type="button" className={tone === "danger" ? "btn-danger" : "btn-primary"} onClick={onConfirm}>{confirmLabel}</button>
    </div>
  </Modal>;
}

type SelectOption = { value: string; label: ReactNode; disabled: boolean };
type SelectChildProps = { value?: string | number; disabled?: boolean; children?: ReactNode };
type SelectProps = {
  value: string | number;
  onChange: (event: { target: { value: string } }) => void;
  children: ReactNode;
  className?: string;
  disabled?: boolean;
  "aria-label"?: string;
  title?: string;
  placeholder?: string;
};
export function Select({ value, onChange, children, className, disabled, title, placeholder = "Select an option", ...aria }: SelectProps) {
  const rootRef = useRef<HTMLDivElement>(null);
  const triggerRef = useRef<HTMLButtonElement>(null);
  const listboxId = useId();
  const [open, setOpen] = useState(false);
  const [active, setActive] = useState(0);
  const options = Children.toArray(children).flatMap((child, index): SelectOption[] => {
    if (!isValidElement<SelectChildProps>(child) || child.type !== "option") return [];
    const optionValue = String(child.props.value ?? index);
    return [{ value: optionValue, label: child.props.children, disabled: !!child.props.disabled }];
  });
  const current = options.find((option) => option.value === String(value));
  const enabledIndices = options.flatMap((option, index) => option.disabled ? [] : [index]);
  const firstEnabled = enabledIndices[0] ?? 0;
  const lastEnabled = enabledIndices[enabledIndices.length - 1] ?? 0;

  useEffect(() => {
    if (!open) return;
    const onPointerDown = (event: MouseEvent) => {
      if (rootRef.current && !rootRef.current.contains(event.target as Node)) setOpen(false);
    };
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") { setOpen(false); triggerRef.current?.focus(); }
      if (event.key === "Tab") setOpen(false);
    };
    document.addEventListener("mousedown", onPointerDown);
    document.addEventListener("keydown", onKeyDown);
    return () => {
      document.removeEventListener("mousedown", onPointerDown);
      document.removeEventListener("keydown", onKeyDown);
    };
  }, [open]);

  const choose = (option: SelectOption) => {
    if (option.disabled) return;
    onChange({ target: { value: option.value } });
    setOpen(false);
    triggerRef.current?.focus();
  };
  const moveActive = (index: number, direction: 1 | -1) => {
    if (!enabledIndices.length) return index;
    let next = index;
    do {
      next = (next + direction + options.length) % options.length;
    } while (options[next].disabled);
    return next;
  };
  const onTriggerKeyDown = (event: ReactKeyboardEvent<HTMLButtonElement>) => {
    if (event.key === "ArrowDown" || event.key === "ArrowUp") {
      event.preventDefault();
      const direction = event.key === "ArrowDown" ? 1 : -1;
      if (!open) {
        setOpen(true);
        setActive(current && !current.disabled ? options.indexOf(current) : direction === 1 ? firstEnabled : lastEnabled);
      } else {
        setActive((index) => moveActive(index, direction));
      }
    } else if (event.key === "Home" || event.key === "End") {
      event.preventDefault();
      setOpen(true);
      setActive(event.key === "Home" ? firstEnabled : lastEnabled);
    } else if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      if (open && options[active]) choose(options[active]);
      else {
        setActive(current && !current.disabled ? options.indexOf(current) : firstEnabled);
        setOpen(true);
      }
    }
  };

  return <div ref={rootRef} className="relative min-w-0">
    <button ref={triggerRef} type="button" title={title} disabled={disabled} {...aria} aria-controls={listboxId} aria-haspopup="listbox" aria-expanded={open}
      aria-activedescendant={open && options[active] ? `${listboxId}-option-${active}` : undefined}
      className={cx("input spot relative flex min-h-11 items-center justify-between gap-3 text-left", className)}
      onClick={() => {
        if (!open) setActive(current && !current.disabled ? options.indexOf(current) : firstEnabled);
        setOpen((wasOpen) => !wasOpen);
      }} onKeyDown={onTriggerKeyDown}>
      <span className={cx("truncate", !current && "text-text-muted/70")}>{current?.label || placeholder}</span>
      <ChevronDown className={cx("h-4 w-4 shrink-0 text-text-muted transition-transform", open && "rotate-180")} />
    </button>
    {open && <div id={listboxId} role="listbox" aria-label={aria["aria-label"]} className="absolute left-0 top-[calc(100%+.5rem)] z-[60] max-h-64 min-w-full overflow-auto rounded-2xl border border-brand-200 bg-white p-1.5 shadow-soft animate-modal-enter">
      {options.map((option, index) => {
        const selected = option.value === String(value);
        return <button key={`${option.value}-${index}`} id={`${listboxId}-option-${index}`} type="button" role="option" aria-selected={selected} disabled={option.disabled}
          className={cx("flex min-h-11 w-full items-center justify-between gap-3 rounded-xl px-3 text-left text-sm transition-colors",
            selected ? "bg-brand-100 font-semibold text-brand-700" : "text-ink hover:bg-brand-50",
            active === index && "ring-1 ring-inset ring-violet/40",
            option.disabled && "cursor-not-allowed opacity-50")}
          onMouseEnter={() => setActive(index)} onClick={() => choose(option)}>{option.label}{selected && <Check className="h-4 w-4 shrink-0" />}</button>;
      })}
      {!options.length && <div className="px-3 py-4 text-center text-sm text-text-muted">No options available</div>}
    </div>}
  </div>;
}

export function Toggle({ checked, onChange, label, disabled }: { checked: boolean; onChange: (checked: boolean) => void; label?: string; disabled?: boolean }) {
  return <button type="button" role="switch" aria-checked={checked} aria-label={label} disabled={disabled}
    onClick={() => onChange(!checked)} className={cx("inline-flex min-h-11 items-center gap-3 text-sm text-slate-700 disabled:opacity-50", !label && "w-12 justify-center")}>
    <span className={cx("relative h-6 w-11 rounded-full border transition-colors", checked ? "border-violet bg-violet" : "border-slate-300 bg-slate-100")}>
      <span className={cx("absolute left-0.5 top-0.5 h-5 w-5 rounded-full bg-white shadow transition-transform", checked && "translate-x-5")} />
    </span>
    {label && <span>{label}</span>}
  </button>;
}

export function Segmented({ items, value, onChange }: { items: { value: string; label: ReactNode }[]; value: string; onChange: (value: string) => void }) {
  return <div role="group" className="inline-flex max-w-full gap-1 rounded-xl border border-brand-200 bg-brand-50 p-1">
    {items.map((item) => <button key={item.value} type="button" aria-pressed={value === item.value} onClick={() => onChange(item.value)}
      className={cx("min-h-10 rounded-lg px-4 py-2 text-sm font-medium", value === item.value ? "bg-white text-brand-700 shadow-sm" : "text-slate-700 hover:text-brand-700")}>{item.label}</button>)}
  </div>;
}

export function Stepper({ steps, current }: { steps: string[]; current: number }) {
  return <ol className="flex max-w-full items-center gap-2 overflow-x-auto py-1">
    {steps.map((step, index) => <li key={step} aria-current={index === current ? "step" : undefined} className="flex shrink-0 items-center gap-2">
      <span className={cx("grid h-8 min-w-8 place-items-center rounded-full px-2 text-xs font-bold", index < current ? "bg-violet text-white" : index === current ? "bg-brand-100 text-brand-700 ring-1 ring-brand-300" : "bg-slate-100 text-slate-700")}>{index < current ? <Check className="h-4 w-4" /> : index + 1}</span>
      <span className={cx("text-xs font-medium", index === current ? "text-ink" : "text-slate-700")}>{step}</span>
      {index < steps.length - 1 && <span aria-hidden="true" className="mx-1 h-px w-5 bg-brand-200" />}
    </li>)}
  </ol>;
}

export function Chip({ children, tone = "teal" }: { children: ReactNode; tone?: "teal" | "lilac" | "sky" | "amber" }) {
  const tones = { teal: "border-brand-200 bg-brand-100 text-brand-700", lilac: "border-brand-200 bg-brand-100 text-brand-700", sky: "border-blue-200 bg-blue-50 text-blue-800", amber: "border-amber-200 bg-amber-50 text-amber-900" };
  return <span className={cx("inline-flex min-h-8 items-center rounded-full border px-3 py-1 text-xs font-medium", tones[tone])}>{children}</span>;
}

export function SectionBar({ icon, title, sub, action }: { icon: ReactNode; title: string; sub?: ReactNode; action?: ReactNode }) {
  return <div className="relative mb-4 flex flex-wrap items-center justify-between gap-3 overflow-hidden rounded-2xl border border-brand-200 bg-brand-50 px-4 py-3">
    <div className="flex min-w-0 items-center gap-3">
      <span className="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-white text-brand-700">{icon}</span>
      <div className="min-w-0"><h2 className="font-heading text-sm font-semibold text-ink">{title}</h2>{sub && <p className="mt-0.5 text-xs text-slate-700">{sub}</p>}</div>
    </div>
    {action && <div className="flex items-center gap-2">{action}</div>}
  </div>;
}

export function confirmAction(msg: string) { return window.confirm(msg); }
