// src/pages/protected/+Page.tsx
import React from 'react';

export function Page() {
  return (
    <div>
      <h1>Protected Page</h1>
      <p>This page is only visible because you are logged in.</p>
    </div>
  );
}