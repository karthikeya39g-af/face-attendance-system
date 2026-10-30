import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// The dev server proxies API calls to FastAPI (no CORS needed). Change the target if your backend port differs.
const target = process.env.VITE_BACKEND_URL || "http://localhost:8000";
export default defineConfig({
  plugins: [react()],
  server: { host: "0.0.0.0", port: 5173, proxy: { "/api": target, "/health": target } },
  build: {
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (/\/node_modules\/(recharts|victory-vendor|d3-[^/]+)\//.test(id)) return "charts-vendor";
          if (/\/node_modules\/(react|react-dom|scheduler)\//.test(id)) return "react-vendor";
        },
      },
    },
  },
});
