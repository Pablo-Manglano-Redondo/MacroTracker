import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react-swc';
import tailwindcss from '@tailwindcss/vite';
import { fileURLToPath } from 'node:url';

const srcDir = fileURLToPath(new URL('./src', import.meta.url));

export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      '@': srcDir,
    },
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (!id.includes('node_modules')) {
            return;
          }

          if (
            id.includes('@supabase/') ||
            id.includes('@tanstack/') ||
            id.includes('react-hook-form') ||
            id.includes('@hookform/')
          ) {
            return 'data';
          }

          if (
            id.includes('@radix-ui/') ||
            id.includes('lucide-react') ||
            id.includes('sonner') ||
            id.includes('qrcode')
          ) {
            return 'ui';
          }

          if (id.includes('react') || id.includes('scheduler')) {
            return 'react-vendor';
          }
        },
      },
    },
  },
});
