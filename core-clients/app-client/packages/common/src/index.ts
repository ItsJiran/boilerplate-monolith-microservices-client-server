export * as api from './api';
export * as store from './store';
export * as schema from './schema';
export * as realtime from './realtime';
export * from './store'; // Also export useAuthStore directly for convenience if preferred, but namespacing is cleaner.
// Actually let's just export * from each so they are all available at top level?
// No, api and store might have conflicts? Not really.
// Let's stick to namespaced exports for clarity, OR spread them.
// 'api' has 'api' and 'axios' and 'useFetch'.
// 'store' has 'useAuthStore'.
// 'schema' has 'LoginSchema', 'UserSchema'.

// Direct exports
export * from './api';
export * from './store';
export * from './schema';
export * from './realtime';
export { default as tailwindConfig } from './config/tailwind.config';
