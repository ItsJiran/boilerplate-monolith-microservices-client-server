import path from "path"
import react from "@vitejs/plugin-react"
import vike from "vike/plugin"
import { defineConfig } from "vite"

export default defineConfig({
  plugins: [react(), vike()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
})