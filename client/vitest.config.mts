import path from "node:path";
import { defineConfig } from "vitest/config";

export default defineConfig({
  resolve: { alias: { "@": import.meta.dirname } },
  // Tests hit the live ABELDent VM over SSH
  test: { testTimeout: 60_000 },
});
