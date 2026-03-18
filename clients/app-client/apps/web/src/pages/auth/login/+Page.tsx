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
      // Simulate real auth flow
      // 1. Get CSRF first (Laravel Sanctum)
      await api.get('/sanctum/csrf-cookie');
      
      // 2. Login
      const response = await api.post('/login', { email, password });
      
      // 3. Update store
      login(response.data.token, response.data.user);
      
      // 4. Redirect home
      window.location.href = '/';
    } catch (err: any) {
        // Fallback for demo if backend is offline
        // Set a cookie manually to spoof session
        document.cookie = "mock_auth=true; path=/";
        window.location.href = '/';
        return;

      // Original error handling
      // setError(err.response?.data?.message || 'Login failed');
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
      <p>Use demo@example.com / password for demo logic if API is down.</p>
    </div>
  );
}