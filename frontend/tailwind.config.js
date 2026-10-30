/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        "bg-deep": "rgb(var(--bg-deep-rgb) / <alpha-value>)",
        "bg-indigo": "rgb(var(--bg-indigo-rgb) / <alpha-value>)",
        surface: { DEFAULT: "rgb(var(--surface-rgb) / <alpha-value>)", 50: "#FFFFFF", 100: "#F1EEFC", glass: "#FFFFFF" },
        brand: {
          50: "#F7F5FF", 100: "#EFEAFE", 200: "#E6E1F7", 300: "#CFC3F7",
          400: "#9276EA", 500: "#6D4AE0", 600: "#5B3BC8", 700: "#4C30AA",
          800: "#392580", 900: "#1F1B3A",
        },
        lilac: "rgb(var(--lilac-rgb) / <alpha-value>)",
        violet: "rgb(var(--violet-rgb) / <alpha-value>)",
        teal: { DEFAULT: "rgb(var(--teal-rgb) / <alpha-value>)", dark: "var(--teal-dark)" },
        "ice-blue": "var(--ice-blue)",
        "ice-blue-hover": "var(--ice-blue-hover)",
        "text-soft": "var(--text-soft)",
        "text-muted": "rgb(var(--text-muted-rgb) / <alpha-value>)",
        ink: "#1F1B3A",
        success: "rgb(var(--success-rgb) / <alpha-value>)",
        warning: "rgb(var(--warning-rgb) / <alpha-value>)",
        danger: "rgb(var(--danger-rgb) / <alpha-value>)",
        info: "rgb(var(--info-rgb) / <alpha-value>)",
      },
      fontFamily: {
        sans: ["Plus Jakarta Sans", "system-ui", "-apple-system", "Segoe UI", "sans-serif"],
        heading: ["Plus Jakarta Sans", "system-ui", "-apple-system", "Segoe UI", "sans-serif"],
      },
      boxShadow: {
        card: "var(--shadow-card)",
        soft: "var(--shadow-soft)",
        glow: "0 8px 24px -12px rgba(76, 48, 170, .18)",
      },
      keyframes: {
        "page-enter": { from: { opacity: "0", transform: "translateX(10px)" }, to: { opacity: "1", transform: "translateX(0)" } },
        "modal-enter": { from: { opacity: "0", transform: "translateY(10px) scale(.99)" }, to: { opacity: "1", transform: "translateY(0) scale(1)" } },
        shimmer: { "100%": { transform: "translateX(100%)" } },
        ripple: { from: { transform: "scale(0)", opacity: ".35" }, to: { transform: "scale(2.5)", opacity: "0" } },
      },
      animation: {
        "page-enter": "page-enter 220ms ease-out both",
        "modal-enter": "modal-enter 200ms ease-out both",
        shimmer: "shimmer 1.6s ease-in-out infinite",
        ripple: "ripple 450ms ease-out",
      },
    },
  },
  plugins: [],
};
