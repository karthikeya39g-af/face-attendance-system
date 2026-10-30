import { lazy, Suspense, useCallback, useEffect, useState } from "react";
import type { ComponentType } from "react";
import { CameraProvider } from "./camera/CameraProvider";
import Layout, { PAGES, PageId, UserRole } from "./components/Layout";
import { Login, RoleSelect, Splash } from "./components/AppFlow";
import { Loading } from "./components/ui";

const Dashboard = lazy(() => import("./pages/Dashboard"));
const Employees = lazy(() => import("./pages/Employees"));
const Recognition = lazy(() => import("./pages/Recognition"));
const Enrollment = lazy(() => import("./pages/Enrollment"));
const Attendance = lazy(() => import("./pages/Attendance"));
const Payroll = lazy(() => import("./pages/Payroll"));
const Leave = lazy(() => import("./pages/Leave"));
const Shifts = lazy(() => import("./pages/Shifts"));
const Offices = lazy(() => import("./pages/Offices"));
const Reports = lazy(() => import("./pages/Reports"));
const AISystem = lazy(() => import("./pages/AISystem"));
const SettingsPage = lazy(() => import("./pages/Settings"));

const VIEWS: Record<PageId, ComponentType> = {
  dashboard: Dashboard, employees: Employees, recognition: Recognition, enrollment: Enrollment, attendance: Attendance,
  payroll: Payroll, leave: Leave, shifts: Shifts, offices: Offices, reports: Reports, ai: AISystem, settings: SettingsPage,
};
const fromHash = (): PageId => {
  const id = window.location.hash.replace(/^#\/?/, "") as PageId;
  return PAGES.some((p) => p.id === id) ? id : "dashboard";
};

function storedRole(): UserRole | null {
  const role = window.localStorage.getItem("veridant-role");
  return role === "admin" ? role : null;
}

function initialRole(): UserRole | null {
  if (fromHash() === "recognition") {
    return storedRole() === "admin" && window.localStorage.getItem("veridant-demo-session") === "active"
      ? "admin"
      : "employee";
  }
  return storedRole();
}

function initialStage(): "splash" | "role" | "login" | "app" {
  if (fromHash() === "recognition") return "app";
  if (window.location.hash) {
    return storedRole() === "admin" && window.localStorage.getItem("veridant-demo-session") === "active"
      ? "app"
      : "role";
  }
  return window.sessionStorage.getItem("veridant-splash-seen") === "true" ? "role" : "splash";
}

export default function App() {
  const [page, setPage] = useState<PageId>(fromHash());
  const [role, setRole] = useState<UserRole | null>(initialRole);
  const [stage, setStage] = useState(initialStage);
  useEffect(() => {
    const f = () => {
      const nextPage = fromHash();
      setPage(nextPage);
      if (nextPage === "recognition" && stage !== "app") {
        setRole("employee");
        setStage("app");
      }
      if (stage === "app" && role === "employee" && nextPage !== "recognition") {
        setRole(null);
        setStage("role");
      }
    };
    window.addEventListener("hashchange", f);
    return () => window.removeEventListener("hashchange", f);
  }, [role, stage]);
  const onSplashDone = useCallback(() => setStage((current) => current === "splash" ? "role" : current), []);
  const go = (p: PageId) => {
    if (role === "admin") window.location.hash = `/${p}`;
  };
  const effectivePage = page;
  const View = VIEWS[effectivePage];
  const selectRole = (nextRole: UserRole) => {
    setRole(nextRole);
    if (nextRole === "employee") {
      window.localStorage.removeItem("veridant-role");
      window.localStorage.removeItem("veridant-demo-session");
      window.localStorage.removeItem("veridant-demo-email");
      window.localStorage.removeItem("veridant-employee-code");
      window.location.hash = "/recognition";
      setStage("app");
    } else {
      setStage("login");
    }
  };
  const login = (email: string, remember: boolean) => {
    if (role !== "admin") { setStage("role"); return; }
    // TODO: Replace this client-side demo session with API-backed authentication.
    window.localStorage.setItem("veridant-role", "admin");
    window.localStorage.setItem("veridant-demo-session", "active");
    if (remember) window.localStorage.setItem("veridant-demo-email", email);
    else window.localStorage.removeItem("veridant-demo-email");
    window.location.hash = "/dashboard";
    setStage("app");
  };
  const logout = () => {
    window.localStorage.removeItem("veridant-demo-session");
    window.localStorage.removeItem("veridant-demo-email");
    window.localStorage.removeItem("veridant-role");
    setRole(null);
    setPage("dashboard");
    window.location.hash = "";
    setStage("role");
  };

  if (stage === "splash") return <Splash onDone={onSplashDone} />;
  if (stage === "role") return <RoleSelect onSelect={selectRole} onBack={() => setStage("splash")} />;
  if (stage === "login" && role) return <Login role={role} onBack={() => setStage("role")}
    onChangeRole={() => setStage("role")} onLogin={login} />;
  if (stage === "app" && role === "employee") return <CameraProvider>
    <Recognition onBack={() => {
      setRole(null);
      setStage("role");
      window.location.hash = "";
    }} kiosk />
  </CameraProvider>;
  if (stage !== "app" || role !== "admin") return <RoleSelect onSelect={selectRole} />;
  // Only the active page is mounted; the camera service keeps ONE stream alive across page changes.
  return (
    <CameraProvider>
      <Layout page={effectivePage} go={go} role={role || "admin"} onLogout={logout}>
        <Suspense fallback={<Loading text="Opening page..." />}><View key={`${role}-${effectivePage}`} /></Suspense>
      </Layout>
    </CameraProvider>
  );
}
