// src/pages/auth/login/+Page.tsx
import React, { useState } from 'react';
import { useAuthStore } from '@repo/common/store';
import { api } from '@repo/common/api';

export function Page() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const login = useAuthStore((state) => state.login);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await api.get('/sanctum/csrf-cookie');

      const response = await api.post<{ data?: { token?: string; user?: unknown }; token?: string; user?: unknown }>(
        '/login',
        { email, password }
      );

      const token = response?.data?.token ?? response?.token ?? null;
      const user = response?.data?.user ?? response?.user ?? null;
      if (token && user) {
        login(token, user);
      }

      window.location.href = '/';
    } catch (err: any) {
      setError(err?.response?.data?.message || 'Login failed');
    }
  };

  return (
    <div>
      <h1>Login</h1>
      <form onSubmit={handleSubmit}>
        <div>
          <label>Email:</label>
          <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
        </div>
        <div>
          <label>Password:</label>
          <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
        </div>
        {error && <p style={{ color: 'red' }}>{error}</p>}
        <button type="submit">Login</button>
      </form>
      <p>Sign in using your backend credentials.</p>
    </div>
  );
}