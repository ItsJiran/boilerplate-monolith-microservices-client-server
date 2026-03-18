// src/renderer/Layout.tsx
import React from 'react';

export function Layout({ children, pageContext }: { children: React.ReactNode, pageContext: any }) {
  const user = pageContext.user;

  return (
    <div className="layout">
      <nav style={{ padding: '10px', borderBottom: '1px solid #ccc', marginBottom: '20px' }}>
        <a href="/" style={{ marginRight: '10px' }}>Home</a>
        <a href="/ssr-test" style={{ marginRight: '10px' }}>SSR Test</a>
        <a href="/guest" style={{ marginRight: '10px' }}>Guest Page</a>
        <a href="/protected" style={{ marginRight: '10px' }}>Protected Page</a>
        {user ? (
          <span style={{ marginLeft: '20px' }}>Hello, {user.name}</span>
        ) : (
          <a href="/auth/login" style={{ marginLeft: '20px' }}>Login</a>
        )}
      </nav>
      <main>
        {children}
      </main>
    </div>
  );
}