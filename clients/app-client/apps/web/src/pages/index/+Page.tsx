import React from 'react';
import { usePageContext } from '@/renderer/usePageContext';

export function Page() {
  const pageContext = usePageContext();
  const { user } = pageContext;
  
  return (
    <>
      <h1>Welcome to Vike + React App</h1>
      <p>This is a boilerplate for client-server structure using Laravel backend.</p>
      
      {user ? (
        <p>Logged in as: {user.name} ({user.email})</p>
      ) : (
        <p>Not logged in. Check out the <a href="/auth/login">Login Page</a>.</p>
      )}

      <h2>Demonstrations:</h2>
      <ul>
        <li><a href="/ssr-test">SSR Data Fetching</a> - Fetches data on the server side.</li>
        <li><a href="/protected">Protected Route</a> - Only accessible if authenticated.</li>
        <li><a href="/guest">Guest Route</a> - Accessible to everyone.</li>
      </ul>
    </>
  );
}