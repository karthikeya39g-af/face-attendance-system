export const EMOJI = {
  brand: "🌿",
  dashboard: "📊",
  employees: "👥",
  recognition: "🎥",
  enrollment: "🪪",
  attendance: "🗓️",
  payroll: "💸",
  leave: "🏖️",
  shifts: "🕒",
  offices: "🏢",
  reports: "📊",
  ai: "🤖",
  settings: "⚙️",
  notifications: "🔔",
  profile: "👤",
  search: "🔍",
  present: "✅",
  late: "⏱️",
  absent: "❌",
  payslip: "🧾",
  empty: "📭",
  warning: "⚠️",
} as const;

export function emojiForLabel(label: string) {
  const normalized = label.toLowerCase();
  const match = Object.entries(EMOJI).find(([key]) => normalized.includes(key));
  return match?.[1];
}
