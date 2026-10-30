import { createContext, ReactNode, useContext, useEffect, useRef, useState } from "react";
import {
  ArrowLeft, Bell, Brain, Building2, CalendarClock, CalendarOff, Camera, ChevronDown, ChevronLeft,
  ChevronRight, ClipboardList, Command, FileBarChart, LayoutDashboard, LogOut, Menu, MoreHorizontal, Search,
  Settings, UserPlus, Users, Wallet, X,
} from "lucide-react";
import { api, useApi } from "../lib/api";
import { fmtDateTime } from "../lib/format";
import AmbientBackground from "./AmbientBackground";
import Logo from "./Logo";
import { Avatar, cx, Drawer, Select, ToastProvider } from "./ui";

export const PAGES = [
  { id: "dashboard", label: "Dashboard", icon: LayoutDashboard },
  { id: "employees", label: "Employees", icon: Users },
  { id: "recognition", label: "Recognition", icon: Camera },
  { id: "enrollment", label: "Enrollment", icon: UserPlus },
  { id: "attendance", label: "Attendance", icon: ClipboardList },
  { id: "payroll", label: "Payroll", icon: Wallet },
  { id: "leave", label: "Leave", icon: CalendarOff },
  { id: "shifts", label: "Shifts", icon: CalendarClock },
  { id: "offices", label: "Offices", icon: Building2 },
  { id: "reports", label: "Reports", icon: FileBarChart },
  { id: "ai", label: "AI System", icon: Brain },
  { id: "settings", label: "Settings", icon: Settings },
] as const;
export type PageId = (typeof PAGES)[number]["id"];
export type UserRole = "admin" | "employee";

const PAGE_GROUPS: { label: string; ids: readonly PageId[] }[] = [
  { label: "Overview", ids: ["dashboard"] },
  { label: "People", ids: ["employees", "recognition", "enrollment"] },
  { label: "Time & pay", ids: ["attendance", "payroll", "leave", "shifts"] },
  { label: "System", ids: ["offices", "reports", "ai", "settings"] },
];

type Shell = { office: string; search: string; setSearch: (s: string) => void; go: (p: PageId) => void };
const ShellCtx = createContext<Shell>({ office: "", search: "", setSearch: () => {}, go: () => {} });
export const useShell = () => useContext(ShellCtx);

export default function Layout({ page, go, children, role = "admin", onLogout }: {
  page: PageId; go: (p: PageId) => void; children: ReactNode; role?: UserRole; onLogout?: () => void;
}) {
  const [office, setOffice] = useState("");
  const [search, setSearch] = useState("");
  const [bell, setBell] = useState(false);
  const [mobileNav, setMobileNav] = useState(false);
  const [collapsed, setCollapsed] = useState(() => window.localStorage.getItem("attendance-sidebar-collapsed") === "true");
  const [moreOpen, setMoreOpen] = useState(false);
  const [profileOpen, setProfileOpen] = useState(false);
  const [commandOpen, setCommandOpen] = useState(false);
  const [direction, setDirection] = useState<"forward" | "backward">("forward");
  const offices = useApi<any[]>("/api/offices");
  const health = useApi<any>("/health", { interval: 15000 });
  const events = useApi<any[]>(bell && role === "admin" ? "/api/admin/events?limit=40" : null);
  const online = !!health.data && !health.error;
  const modelsOk = health.data?.models_loaded;
  const bellRef = useRef<HTMLDivElement>(null);
  const profileRef = useRef<HTMLDivElement>(null);
  const pageHistory = useRef<PageId[]>([]);
  const currentPage = PAGES.find((item) => item.id === page);

  useEffect(() => { document.documentElement.dataset.theme = "light"; }, []);
  useEffect(() => {
    setMobileNav(false);
    if (pageHistory.current[pageHistory.current.length - 1] !== page) pageHistory.current.push(page);
  }, [page]);
  useEffect(() => {
    if (!mobileNav && !moreOpen) return;
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") { setMobileNav(false); setMoreOpen(false); }
    };
    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    window.addEventListener("keydown", onKeyDown);
    return () => {
      document.body.style.overflow = previousOverflow;
      window.removeEventListener("keydown", onKeyDown);
    };
  }, [mobileNav, moreOpen]);
  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent) => {
      if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k") {
        event.preventDefault();
        setCommandOpen((open) => !open);
      }
      if (event.key === "Escape") setCommandOpen(false);
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, []);
  useEffect(() => {
    const onMouseDown = (event: MouseEvent) => {
      if (bellRef.current && !bellRef.current.contains(event.target as Node)) setBell(false);
      if (profileRef.current && !profileRef.current.contains(event.target as Node)) setProfileOpen(false);
    };
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") { setBell(false); setProfileOpen(false); }
    };
    document.addEventListener("mousedown", onMouseDown);
    document.addEventListener("keydown", onKeyDown);
    return () => {
      document.removeEventListener("mousedown", onMouseDown);
      document.removeEventListener("keydown", onKeyDown);
    };
  }, []);

  const alerts = (events.data || []).filter((event) => ["UNKNOWN_FACE", "LIVENESS_REJECTED"].includes(event.type)).slice(0, 8);
  const alertError = events.error;
  const alertLoading = events.loading;
  const mobileTabs = [{ id: "dashboard" as PageId, label: "Home" }, { id: "employees" as PageId, label: "People" },
    { id: "attendance" as PageId, label: "Time" }, { id: "payroll" as PageId, label: "Pay" }];
  const navigate = (nextPage: PageId, backward = false) => {
    setDirection(backward || (pageHistory.current.length > 1 && pageHistory.current[pageHistory.current.length - 2] === nextPage) ? "backward" : "forward");
    go(nextPage);
  };
  const goBack = () => {
    const previous = pageHistory.current.length > 1 ? pageHistory.current[pageHistory.current.length - 2] : "dashboard";
    if (pageHistory.current.length > 1) pageHistory.current.pop();
    navigate(role === "employee" && previous !== "dashboard" && previous !== "recognition" ? "dashboard" : previous, true);
  };
  const toggleCollapsed = () => {
    setCollapsed((value) => {
      window.localStorage.setItem("attendance-sidebar-collapsed", String(!value));
      return !value;
    });
  };
  const onSearchSubmit = () => {
    if (role === "admin" && search.trim()) navigate("employees");
    else if (search.trim()) setCommandOpen(true);
  };

  return (
    <ToastProvider>
      <ShellCtx.Provider value={{ office, search, setSearch, go: navigate }}>
        <div className="relative isolate flex min-h-screen bg-bg-deep text-text-soft">
          <AmbientBackground />
          <aside className={cx("sticky top-0 z-20 hidden h-screen shrink-0 flex-col border-r border-brand-200 bg-white transition-[width] duration-200 md:flex", collapsed ? "w-[76px]" : "w-64", role === "employee" && "md:hidden")}>
            <SidebarHeader collapsed={collapsed} />
            <SidebarNav page={page} collapsed={collapsed} role={role} onNavigate={navigate} />
            <button type="button" aria-label={collapsed ? "Expand sidebar" : "Collapse sidebar"} onClick={toggleCollapsed}
              className="mx-3 mb-4 flex min-h-11 items-center justify-center gap-2 rounded-xl text-slate-600 hover:bg-brand-50 hover:text-brand-700">
              {collapsed ? <ChevronRight className="h-4 w-4" /> : <><ChevronLeft className="h-4 w-4" /><span className="text-xs">Collapse menu</span></>}
            </button>
          </aside>

          <div className="relative z-10 min-w-0 flex-1 pb-[calc(4.75rem+env(safe-area-inset-bottom))] md:pb-0">
            <header className="sticky top-0 z-30 border-b border-brand-200 bg-white/95 px-3 backdrop-blur-xl sm:px-5 lg:px-8">
              <div className="mx-auto flex min-h-[68px] max-w-[1440px] items-center gap-2 sm:gap-3">
                {role === "admin" && <button type="button" aria-label="Open navigation menu" onClick={() => setMobileNav(true)} className="btn-ghost !h-11 !w-11 !p-0 md:hidden"><Menu className="h-5 w-5" /></button>}
                {page !== "dashboard" && <button type="button" aria-label="Go back" onClick={goBack} className="btn-ghost !h-11 !w-11 !p-0"><ArrowLeft className="h-5 w-5" /></button>}
                <div className="flex min-w-0 flex-1 items-center gap-2 sm:gap-3">
                  <Logo size={30} />
                  <div className="min-w-0">
                    <div className="truncate text-base font-semibold text-ink sm:text-lg">{currentPage?.label || "Dashboard"}</div>
                    <div className="hidden text-xs text-slate-600 sm:block">VERIDANT · Attendance and payroll</div>
                  </div>
                </div>
                <button type="button" aria-label="Open command palette" className="btn-ghost hidden !h-11 !w-11 !p-0 sm:inline-flex" onClick={() => setCommandOpen(true)}><Command className="h-4 w-4" /></button>
                {role === "admin" && <div className="hidden md:block"><OfficeSelect offices={offices.data || []} value={office} onChange={setOffice} /></div>}
                <div className="relative" ref={bellRef}>
                  <button type="button" aria-label="Recent alerts" aria-expanded={bell} className="btn-ghost relative !h-11 !w-11 !p-0" onClick={() => setBell((value) => !value)}>
                    <Bell className="h-4 w-4" />
                    {alerts.length > 0 && <span className="absolute right-2 top-2 h-2 w-2 rounded-full bg-danger ring-2 ring-white" />}
                  </button>
                  {bell && <div className="card absolute right-0 top-12 z-40 w-[min(20rem,calc(100vw-1.5rem))] p-2 shadow-soft">
                    <div className="px-3 py-2 text-sm font-semibold text-ink">Recent alerts</div>
                    {alertLoading && <div className="p-3 text-sm text-slate-600">Loading alerts...</div>}
                    {alertError && <div role="alert" className="p-3 text-sm text-danger">{alertError}</div>}
                    {!alertLoading && !alertError && alerts.length === 0 && <div className="p-3 text-sm text-slate-600">No alerts</div>}
                    {alerts.map((alert, index) => <div key={alert.id || index} className="flex justify-between gap-3 rounded-xl px-3 py-2 text-sm hover:bg-brand-50">
                      <span>{role === "admin" ? (alert.type === "UNKNOWN_FACE" ? "Unknown face" : "Spoof attempt") : String(alert.type || "Notification").replace(/_/g, " ").toLowerCase()}</span>
                      <span className="shrink-0 text-xs text-slate-600">{fmtDateTime(alert.created_at || alert.at)}</span>
                    </div>)}
                  </div>}
                </div>
                <span role="status" className={cx("hidden items-center gap-2 rounded-full px-3 py-2 text-xs font-semibold lg:flex", online && modelsOk ? "border border-emerald-200 bg-emerald-50 text-emerald-800" : "border border-rose-200 bg-rose-50 text-rose-800")}>
                  <span className={cx("h-2 w-2 rounded-full", online && modelsOk ? "bg-emerald-600" : "bg-rose-600")} />
                  {online ? (modelsOk ? "System online" : "Models not loaded") : "Backend offline"}
                </span>
                <div className="relative" ref={profileRef}>
                  <button type="button" aria-label="Profile menu" aria-expanded={profileOpen} onClick={() => setProfileOpen((open) => !open)}
                    className="flex min-h-11 items-center gap-2 rounded-full border border-brand-200 bg-white py-1 pl-1 pr-2 text-sm font-medium text-ink hover:bg-brand-50">
                    <Avatar name={role === "admin" ? "Admin" : "Employee"} className="h-8 w-8 text-xs" />
                    <span className="hidden sm:inline">{role === "admin" ? "Admin" : "Employee"}</span>
                    <ChevronDown className="hidden h-4 w-4 text-slate-600 sm:block" />
                  </button>
                  {profileOpen && onLogout && <div className="card absolute right-0 top-full z-40 mt-2 w-44 p-1 shadow-soft">
                    <button type="button" className="flex min-h-11 w-full items-center gap-2 rounded-lg px-3 text-left text-sm text-ink hover:bg-brand-50" onClick={() => { setProfileOpen(false); onLogout(); }}>
                      <LogOut className="h-4 w-4" />Log out
                    </button>
                  </div>}
                </div>
              </div>
              <div className="mx-auto max-w-[1440px] pb-3">
                <div className="relative">
                  <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-600" />
                  <input aria-label="Search employees or pages" className="input !min-h-11 !rounded-xl !bg-brand-50 !py-2 !pl-10 !pr-16"
                    placeholder="Search employees or pages" value={search} onChange={(event) => setSearch(event.target.value)}
                    onKeyDown={(event) => event.key === "Enter" && onSearchSubmit()} />
                  <button type="button" aria-label="Search pages and employees" onClick={() => setCommandOpen(true)}
                    className="absolute right-1 top-1/2 grid h-9 w-10 -translate-y-1/2 place-items-center rounded-lg text-slate-600 hover:bg-white hover:text-brand-700"><Search className="h-4 w-4" /></button>
                </div>
              </div>
            </header>
            {!online && !health.loading && <div role="alert" className="mx-4 mt-4 flex flex-wrap items-center justify-between gap-3 rounded-2xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-800 sm:mx-5 lg:mx-8">
              <span><strong>Backend offline.</strong> {health.error || "The server is not responding."}</span>
              <button type="button" className="btn-ghost btn-sm !border-rose-200 !text-rose-800" onClick={() => health.reload()}>Retry connection</button>
            </div>}
            <main className="mx-auto max-w-[1440px] p-4 sm:p-5 lg:p-8">
              <div key={page} className={direction === "backward" ? "animate-page-back" : "animate-page-enter"}>{children}</div>
            </main>
          </div>

          {mobileNav && <div className="fixed inset-0 z-50 md:hidden">
            <button type="button" aria-label="Close navigation menu" className="absolute inset-0 bg-ink/25 backdrop-blur-sm" onClick={() => setMobileNav(false)} />
            <aside aria-label="Main navigation" className="relative flex h-full w-[min(21rem,86vw)] flex-col border-r border-brand-200 bg-white shadow-xl">
              <div className="flex items-center justify-between pr-3"><SidebarHeader collapsed={false} />
                <button type="button" aria-label="Close navigation menu" onClick={() => setMobileNav(false)} className="btn-ghost btn-sm"><X className="h-5 w-5" /></button>
              </div>
              <SidebarNav page={page} collapsed={false} role={role} onNavigate={(nextPage) => { setMobileNav(false); navigate(nextPage); }} />
            </aside>
          </div>}
          <nav aria-label="Quick navigation" className="fixed inset-x-0 bottom-0 z-30 flex items-center justify-around border-t border-brand-200 bg-white/95 px-2 pb-[env(safe-area-inset-bottom)] pt-1.5 backdrop-blur-xl md:hidden">
            {mobileTabs.map((tab) => {
              const item = PAGES.find((entry) => entry.id === tab.id)!;
              const Icon = item.icon;
              return <button key={tab.id} type="button" aria-current={page === tab.id ? "page" : undefined} onClick={() => navigate(tab.id)}
                className={cx("relative flex min-h-12 min-w-14 flex-col items-center justify-center gap-0.5 rounded-xl px-3 text-[10px] font-medium", page === tab.id ? "text-brand-700" : "text-slate-600")}>
                <Icon className="h-5 w-5" />{tab.label}
                {page === tab.id && <span aria-hidden="true" className="absolute -top-1 h-1 w-6 rounded-full bg-violet" />}
              </button>;
            })}
            {role === "admin" && <button type="button" aria-expanded={moreOpen} onClick={() => setMoreOpen(true)}
              className="flex min-h-12 min-w-14 flex-col items-center justify-center gap-0.5 rounded-xl px-3 text-[10px] font-medium text-slate-600">
              <MoreHorizontal className="h-5 w-5" />More
            </button>}
          </nav>
          {moreOpen && <Drawer title="More pages" onClose={() => setMoreOpen(false)}>
            <nav aria-label="More pages" className="grid grid-cols-2 gap-2">
              {PAGES.filter((item) => !mobileTabs.some((tab) => tab.id === item.id)).map(({ id, label, icon: Icon }) => <button key={id} type="button"
                aria-current={page === id ? "page" : undefined} className={cx("btn-ghost justify-start", page === id && "bg-brand-100 text-brand-700")}
                onClick={() => { setMoreOpen(false); navigate(id); }}><Icon className="h-4 w-4" />{label}</button>)}
            </nav>
            {onLogout && <button type="button" className="btn-danger mt-4 w-full" onClick={() => { setMoreOpen(false); onLogout(); }}><LogOut className="h-4 w-4" />Log out</button>}
          </Drawer>}
          {commandOpen && <CommandPalette role={role} initialQuery={search} onClose={() => setCommandOpen(false)} onSearch={setSearch} onNavigate={(nextPage) => { setCommandOpen(false); navigate(nextPage); }} />}
        </div>
      </ShellCtx.Provider>
    </ToastProvider>
  );
}

function CommandPalette({ role, initialQuery, onClose, onSearch, onNavigate }: {
  role: UserRole; initialQuery?: string; onClose: () => void; onSearch: (value: string) => void; onNavigate: (page: PageId) => void;
}) {
  const [query, setQuery] = useState(initialQuery || "");
  const [activeIndex, setActiveIndex] = useState(0);
  const employees = useApi<any[]>(role === "admin" ? "/api/admin/employees" : null);
  const normalized = query.trim().toLowerCase();
  const pages = PAGES.filter((item) => (role === "admin" || item.id === "dashboard" || item.id === "recognition")
    && (!normalized || item.label.toLowerCase().includes(normalized)));
  const matchingEmployees = (employees.data || []).filter((employee) => normalized
    && `${employee.name} ${employee.employee_code}`.toLowerCase().includes(normalized)).slice(0, 6);
  const resultCount = pages.length + matchingEmployees.length;
  useEffect(() => setActiveIndex(0), [normalized]);
  useEffect(() => {
    const previousFocus = document.activeElement instanceof HTMLElement ? document.activeElement : null;
    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = previousOverflow;
      previousFocus?.focus();
    };
  }, []);
  const choose = (index: number) => {
    if (index < pages.length) onNavigate(pages[index].id);
    else {
      const employee = matchingEmployees[index - pages.length];
      if (employee) { onSearch(employee.name); onNavigate("employees"); }
    }
  };

  return <div className="fixed inset-0 z-[70] grid place-items-start bg-ink/25 px-4 pt-[12vh] backdrop-blur-sm" onMouseDown={(event) => event.target === event.currentTarget && onClose()}>
    <div role="dialog" aria-modal="true" aria-label="Command palette" className="card mx-auto w-full max-w-xl overflow-hidden p-2 shadow-soft" onKeyDown={(event) => {
      if (event.key === "Escape") onClose();
      if (event.key === "Tab") {
        const focusable = event.currentTarget.querySelectorAll<HTMLElement>('input:not([disabled]), button:not([disabled])');
        const first = focusable[0];
        const last = focusable[focusable.length - 1];
        if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last?.focus(); }
        else if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first?.focus(); }
      }
    }}>
      <div className="flex items-center gap-3 border-b border-brand-200 px-3">
        <Search className="h-5 w-5 shrink-0 text-slate-600" />
        <input autoFocus role="combobox" aria-expanded={resultCount > 0} aria-controls="command-results" aria-activedescendant={resultCount ? `command-option-${activeIndex}` : undefined}
          aria-label="Search pages and employees" className="min-h-14 min-w-0 flex-1 bg-transparent text-sm text-ink outline-none placeholder:text-slate-600" placeholder="Search pages and employees..." value={query}
          onChange={(event) => setQuery(event.target.value)} onKeyDown={(event) => {
            if (event.key === "ArrowDown" && resultCount) { event.preventDefault(); setActiveIndex((index) => (index + 1) % resultCount); }
            if (event.key === "ArrowUp" && resultCount) { event.preventDefault(); setActiveIndex((index) => (index - 1 + resultCount) % resultCount); }
            if (event.key === "Enter" && resultCount) { event.preventDefault(); choose(activeIndex); }
          }} />
        <kbd className="rounded-md border border-brand-200 px-1.5 py-0.5 text-[10px] text-slate-600">Esc</kbd>
      </div>
      <div id="command-results" role="listbox" aria-label="Command results" className="max-h-[60vh] overflow-y-auto p-2">
        {pages.length > 0 && <div className="px-3 pb-1 pt-2 text-[10px] font-semibold text-slate-600">Pages</div>}
        {pages.map(({ id, label, icon: Icon }, index) => <button key={id} id={`command-option-${index}`} role="option" aria-selected={activeIndex === index} type="button"
          className={cx("flex min-h-11 w-full items-center gap-3 rounded-xl px-3 text-left text-sm text-ink", activeIndex === index ? "bg-brand-100" : "hover:bg-brand-50")}
          onMouseEnter={() => setActiveIndex(index)} onClick={() => onNavigate(id)}>
          <Icon className="h-4 w-4 text-brand-700" />{label}<span className="ml-auto text-xs text-slate-600">Open</span>
        </button>)}
        {matchingEmployees.length > 0 && <div className="px-3 pb-1 pt-3 text-[10px] font-semibold text-slate-600">Employees</div>}
        {matchingEmployees.map((employee, index) => <button key={employee.employee_code} id={`command-option-${pages.length + index}`} role="option" aria-selected={activeIndex === pages.length + index} type="button"
          className={cx("flex min-h-11 w-full items-center gap-3 rounded-xl px-3 text-left text-sm text-ink", activeIndex === pages.length + index ? "bg-brand-100" : "hover:bg-brand-50")}
          onMouseEnter={() => setActiveIndex(pages.length + index)} onClick={() => { onSearch(employee.name); onNavigate("employees"); }}>
          <Users className="h-4 w-4 text-brand-700" /><span>{employee.name}</span><span className="ml-auto text-xs text-slate-600">#{employee.employee_code}</span>
        </button>)}
        {employees.error && <div role="alert" className="px-3 py-2 text-sm text-danger">{employees.error}</div>}
        {!pages.length && !matchingEmployees.length && <p className="px-3 py-6 text-center text-sm text-slate-600">{normalized ? "No matching pages or employees" : role === "admin" ? "Type to find a page or employee" : "No matching pages"}</p>}
      </div>
      <div className="border-t border-brand-200 px-3 py-2 text-[10px] text-slate-600">Press Ctrl/⌘ K to open this palette</div>
    </div>
  </div>;
}

function SidebarHeader({ collapsed }: { collapsed: boolean }) {
  return <div className={cx("flex min-h-[76px] items-center border-b border-brand-200", collapsed ? "justify-center px-2" : "gap-3 px-5")}>
    <Logo size={40} withWordmark={!collapsed} />
  </div>;
}

function SidebarNav({ page, collapsed, role, onNavigate }: { page: PageId; collapsed: boolean; role: UserRole; onNavigate: (page: PageId) => void }) {
  const visiblePages = role === "admin" ? PAGES : PAGES.filter((item) => item.id === "dashboard" || item.id === "recognition");
  return <nav aria-label="Main navigation" className="flex-1 space-y-5 overflow-y-auto px-3 py-5">
    {PAGE_GROUPS.map((group) => <section key={group.label}>
      {!collapsed && <h2 className="mb-2 px-3 text-[11px] font-semibold text-slate-600">{group.label}</h2>}
      <div className="space-y-1">
        {visiblePages.filter((item) => group.ids.includes(item.id)).map(({ id, label, icon: Icon }) => {
          const active = page === id;
          return <button key={id} type="button" aria-label={label} aria-current={active ? "page" : undefined} title={collapsed ? label : undefined}
            onClick={() => onNavigate(id)}
            className={cx("spot relative flex min-h-11 w-full items-center gap-3 rounded-xl px-3 text-left text-sm transition-all duration-200",
              collapsed && "justify-center px-0", active ? "bg-brand-100 font-semibold text-brand-700" : "text-slate-700 hover:bg-brand-50 hover:text-brand-700")}>
            <Icon className="h-[18px] w-[18px] shrink-0" />
            {!collapsed && <span className="truncate">{label}</span>}
            {active && <span aria-hidden="true" className="absolute bottom-2 left-0 top-2 w-0.5 rounded-r bg-violet" />}
          </button>;
        })}
      </div>
    </section>)}
  </nav>;
}

function OfficeSelect({ offices, value, onChange }: { offices: any[]; value: string; onChange: (v: string) => void }) {
  return <Select aria-label="Office filter" className="!w-auto !min-w-0 !max-w-[8.5rem] !px-2.5 !py-2 sm:!max-w-40"
    value={value} onChange={(event) => onChange(event.target.value)} title="Office filter">
    <option value="">All offices</option>
    {offices.map((office) => <option key={office.code} value={office.code}>{office.name}</option>)}
  </Select>;
}
export { api };
