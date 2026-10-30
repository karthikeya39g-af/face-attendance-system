import { cx } from "./ui";

export function Logo({ size = 40, withWordmark = false, className }: { size?: number; withWordmark?: boolean; className?: string }) {
  return (
    <span className={cx("inline-flex min-w-0 items-center gap-3", className)}>
      <svg aria-hidden="true" viewBox="0 0 48 48" width={size} height={size} className="shrink-0">
        <rect width="48" height="48" rx="13" fill="#6D4AE0" />
        <path className="logo-check" d="M12.5 14.5 23.1 34a1 1 0 0 0 1.7 0l10.7-19.5" fill="none" stroke="#FFFFFF" strokeLinecap="round" strokeLinejoin="round" strokeWidth="3.6" />
      </svg>
      {withWordmark && <span className="truncate font-heading text-base font-semibold tracking-wide text-ink">Veridant</span>}
    </span>
  );
}

export default Logo;
