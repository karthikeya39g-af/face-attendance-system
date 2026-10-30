export const inr = (n: number | null | undefined) =>
  n === null || n === undefined ? "-" : new Intl.NumberFormat("en-IN", { style: "currency", currency: "INR", maximumFractionDigits: 2 }).format(n);
export const inrShort = (n: number | null | undefined) => {
  if (n === null || n === undefined) return "-";
  const a = Math.abs(n);
  if (a >= 1e7) return `₹${(n / 1e7).toFixed(2)} Cr`;
  if (a >= 1e5) return `₹${(n / 1e5).toFixed(2)} L`;
  if (a >= 1e3) return `₹${(n / 1e3).toFixed(1)} K`;
  return `₹${n.toFixed(0)}`;
};
export const fmtTime = (iso?: string | null) =>
  iso ? new Date(iso).toLocaleTimeString("en-GB", { hour: "2-digit", minute: "2-digit" }) : "—";
export const fmtDateTime = (iso?: string | null) =>
  iso ? new Date(iso).toLocaleString("en-GB", { day: "2-digit", month: "short", hour: "2-digit", minute: "2-digit" }) : "—";
export const fmtHM = (min?: number | null) => (min === null || min === undefined || min === 0 ? "—" : `${Math.floor(min / 60)}h ${String(min % 60).padStart(2, "0")}m`);
export const isoDate = (d: Date) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
export const monthName = (m: number) => new Date(2000, m - 1, 1).toLocaleString("en", { month: "long" });
export const greeting = () => { const h = new Date().getHours(); return h < 12 ? "Good morning" : h < 17 ? "Good afternoon" : "Good evening"; };

export const HINTS: Record<string, string> = {
  no_face_detected: "No face found - look at the camera", face_too_small: "Too small - move closer",
  face_area_too_small: "Too small - move closer", image_too_blurry: "Too blurry - hold still / add light",
  multiple_faces: "Multiple faces - only one person in view", spoof_detected: "Spoof detected - real face only",
  duplicate_frame: "Duplicate sample - change your pose a little",
  different_person_or_pose_outlier: "Inconsistent sample - face the camera",
  below_threshold: "Unknown face", insufficient_margin: "Not sure who this is - try again",
  gallery_empty: "No employees enrolled yet", employee_inactive: "Employee is inactive",
};
