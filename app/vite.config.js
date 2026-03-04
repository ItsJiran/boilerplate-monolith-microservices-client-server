import { defineConfig, loadEnv } from 'vite';
import laravel from 'laravel-vite-plugin';
import react from '@vitejs/plugin-react';

export default defineConfig(({ mode }) => {
    // Memuat variabel env dari file .env* 
    const env = loadEnv(mode, process.cwd(), '');

    // Production detection yang lebih robust
    // 1. mode === 'production' -> dari 'vite build' command
    // 2. VITE_APP_ENV === 'production' -> dari env variable (harus pakai VITE_ prefix)
    // 3. APP_ENV === 'production' -> fallback untuk backwards compatibility
    // 4. NODE_ENV === 'production' -> standard node environment
    const isProduction =
        mode === 'production' ||
        env.VITE_APP_ENV === 'production' ||
        env.APP_ENV === 'production' ||
        process.env.NODE_ENV === 'production';

    console.log('🔧 Vite Mode:', mode);
    console.log('🏭 Is Production:', isProduction);
    console.log('📦 APP_ENV:', env.APP_ENV);
    console.log('📦 VITE_APP_ENV:', env.VITE_APP_ENV);

    return {
        // Production: disable dev server config
        // Development: enable HMR and dev server
        server: isProduction ? undefined : {
            host: '0.0.0.0',
            port: 5173,
            strictPort: true,
            hmr: {
                protocol: 'wss',
                host: 'app.test',
                clientPort: 5174,
            },
        },
        plugins: [
            laravel({
                input: 'resources/js/app.jsx',
                refresh: true,
            }),
            react(),
        ],
    };
});