// src/renderer/+onBeforeRender.ts
// This hook is run on the server before rendering the page associated with the URL.
// We use it to verify the user authentication state (session spoofing check)

import { PageContextServer } from '@/renderer/types';
// import { api } from '@repo/common/api'; // Not used in this mocked version

export const onBeforeRender = async (pageContext: PageContextServer) => {
  // Extract headers passed from Express server
  const { headers } = pageContext;
  
  // Initialize user as null
  let user = null;

  if (headers && headers.cookie) {
    // try {
      // Attempt to fetch current user from Laravel
      // Since we pass the Cookie header, Laravel Sanctum will authenticate the request
      // const user = await api.get('/api/user', { headers: { Cookie: headers.cookie } });
    // } catch (e) { ... }

    // MOCK USER FOR NOW since backend might not be ready
    // If "mock_auth=true" cookie exists, we simulate logged in user
    if (headers.cookie.includes('mock_auth=true')) {
        user = {
          name: 'Mock User',
          email: 'mock@example.com'
        };
    }
  }

  return {
    pageContext: {
      user
    }
  };
};