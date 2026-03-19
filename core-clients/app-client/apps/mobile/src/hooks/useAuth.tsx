import React, { createContext, useContext, useState, ReactNode } from 'react';
import { api } from '@repo/common/api';

interface User {
  id?: number;
  name: string;
  email: string;
}

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(false);

  const login = async (email: string, password: string) => {
    setLoading(true);
    try {
      await api.get('/sanctum/csrf-cookie');

      const response = (await api.post('/login', {
        email,
        password,
      })) as { data?: { user?: User }; user?: User };

      const authenticatedUser = response?.data?.user ?? response?.user;
      if (authenticatedUser) {
        setUser(authenticatedUser);
      } else {
        // Fallback if API doesn't return full user payload.
        setUser({ name: email.split('@')[0] || 'User', email });
      }
    } finally {
      setLoading(false);
    }
  };

  const logout = async () => {
    try {
      await api.post('/logout');
    } finally {
      setUser(null);
    }
  };

  return (
    <AuthContext.Provider value={{ 
      user, 
      isAuthenticated: !!user, 
      login, 
      logout,
      loading 
    }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
