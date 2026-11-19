import { defineConfig } from 'vite';
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig({
  build: { outDir: 'build' },
  plugins: [VitePWA({ filename: 'service-worker.js', manifest: false, injectRegister: false, workbox: { globPatterns: ['**/*.{html,js,css,svg,ico,json}'] } })],
});
