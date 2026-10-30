import { useState } from "react";
import { cx } from "./ui";

export type LoginMascotState = "idle" | "email" | "password" | "error" | "success";

export default function LoginMascot({ state, showPassword = false }: { state: LoginMascotState; showPassword?: boolean }) {
  const [gaze, setGaze] = useState({ x: 0, y: 0 });
  const covered = state === "password" && !showPassword;

  return <div className="login-mascot" onPointerMove={(event) => {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches || state === "password") return;
    const bounds = event.currentTarget.getBoundingClientRect();
    setGaze({
      x: Math.max(-1.5, Math.min(1.5, ((event.clientX - bounds.left) / bounds.width - 0.5) * 3)),
      y: Math.max(-1, Math.min(1, ((event.clientY - bounds.top) / bounds.height - 0.5) * 2)),
    });
  }} aria-hidden="true">
    <svg viewBox="0 0 240 250" className={cx("login-mascot-art", `mascot-${state}`)} role="presentation">
      <ellipse cx="120" cy="231" rx="67" ry="10" fill="#392580" fillOpacity=".13" />
      <g className="mascot-body">
        <path d="M72 205c4-37 22-56 48-56s44 19 48 56v15H72z" fill="#EFEAFE" stroke="#6D4AE0" strokeWidth="4" />
        <path d="M105 159l15 19 15-19" fill="none" stroke="#6D4AE0" strokeLinecap="round" strokeLinejoin="round" strokeWidth="4" />
        <path d="M112 177h16l9 35h-34z" fill="#6D4AE0" />
      </g>
      <g className="mascot-head">
        <circle cx="120" cy="93" r="67" fill="#FFFFFF" stroke="#6D4AE0" strokeWidth="5" />
        <path d="M82 46c12-15 31-23 51-20" fill="none" stroke="#B6A2F5" strokeLinecap="round" strokeWidth="7" />
        <g className="mascot-eyes">
          <ellipse className="mascot-eye" cx={101 + gaze.x} cy={91 + gaze.y} rx="7" ry="9" fill="#1F1B3A" />
          <ellipse className="mascot-eye" cx={139 + gaze.x} cy={91 + gaze.y} rx="7" ry="9" fill="#1F1B3A" />
          <circle cx={103 + gaze.x} cy={88 + gaze.y} r="2" fill="#FFFFFF" />
          <circle cx={141 + gaze.x} cy={88 + gaze.y} r="2" fill="#FFFFFF" />
        </g>
        <path className={cx("mascot-mouth", state === "error" && "mascot-mouth-sad", state === "success" && "mascot-mouth-smile")}
          d={state === "error" ? "M109 121c6-8 16-8 22 0" : "M110 118c5 5 15 5 20 0"} fill="none" stroke="#4C30AA" strokeLinecap="round" strokeWidth="4" />
        <path d="M81 108h10M149 108h10" stroke="#E8688A" strokeLinecap="round" strokeWidth="4" opacity=".55" />
        {covered && <g className="mascot-hands" fill="#B6A2F5" stroke="#6D4AE0" strokeWidth="3">
          <path d="M83 92c-8-8-7-20 1-25 8-5 17 0 22 10l8 16-12 12z" />
          <path d="M157 92c8-8 7-20-1-25-8-5-17 0-22 10l-8 16 12 12z" />
        </g>}
      </g>
    </svg>
  </div>;
}
