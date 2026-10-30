import { useEffect, useRef } from "react";

export default function AmbientBackground() {
  const rootRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const root = rootRef.current;
    if (!root) return;

    const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (reducedMotion) return;
    let targetX = 0;
    let targetY = 0;
    let currentX = 0;
    let currentY = 0;
    let animationFrame = 0;

    const animate = () => {
      currentX += (targetX - currentX) * 0.08;
      currentY += (targetY - currentY) * 0.08;
      root.style.setProperty("--mx", `${currentX.toFixed(2)}px`);
      root.style.setProperty("--my", `${currentY.toFixed(2)}px`);
      if (Math.abs(targetX - currentX) > 0.15 || Math.abs(targetY - currentY) > 0.15) {
        animationFrame = window.requestAnimationFrame(animate);
      } else {
        animationFrame = 0;
      }
    };

    const onPointerMove = (event: PointerEvent) => {
      if (event.pointerType !== "mouse" || window.matchMedia("(hover: none)").matches) return;
      targetX = Math.max(-30, Math.min(30, (event.clientX / window.innerWidth - 0.5) * 60));
      targetY = Math.max(-30, Math.min(30, (event.clientY / window.innerHeight - 0.5) * 60));
      const target = event.target instanceof Element ? event.target.closest<HTMLElement>(".spot") : null;
      if (target) {
        const bounds = target.getBoundingClientRect();
        target.style.setProperty("--x", `${event.clientX - bounds.left}px`);
        target.style.setProperty("--y", `${event.clientY - bounds.top}px`);
      }
      if (!animationFrame) animationFrame = window.requestAnimationFrame(animate);
    };

    window.addEventListener("pointermove", onPointerMove, { passive: true });
    return () => {
      window.removeEventListener("pointermove", onPointerMove);
      if (animationFrame) window.cancelAnimationFrame(animationFrame);
    };
  }, []);

  return (
    <div ref={rootRef} aria-hidden="true" className="ambient-background pointer-events-none fixed inset-0 -z-10 overflow-hidden">
      <div className="ambient-blob ambient-violet" />
      <div className="ambient-blob ambient-sky" />
      <div className="ambient-blob ambient-lilac" />
    </div>
  );
}
