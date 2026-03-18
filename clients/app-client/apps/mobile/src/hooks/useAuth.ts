// src/hooks/useAuth.ts
import { create } from 'zustand';

// Simple mocked auth store mimicking the web's session
interface AuthState {
  user: { name: string; email: string } | null;
  login: (email: string) => void;
  logout: () => void;
  isAuthenticated: boolean;
}

export const useAuth = create<AuthState>((set) => ({
  user: null,
  isAuthenticated: false,
  login: (email: string) => set({ 
    user: { name: 'Test User', email }, 
    isAuthenticated: true 
  }),
  logout: () => set({ user: null, isAuthenticated: false }),
}));
