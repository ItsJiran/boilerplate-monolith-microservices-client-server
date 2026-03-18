// src/pages/ssr-test/+onBeforeRender.ts
// This page specific onBeforeRender runs AFTER the global one in renderer/+onBeforeRender.ts
// We use it to fetch data required *only* for this page.

import { PageContextServer } from '@/renderer/types';

export const onBeforeRender = async (pageContext: PageContextServer) => {
  // We can access user info here if needed
  // const { user } = pageContext;
  
  // Simulated API call (replace with real axios call)
  const posts = [
    { id: 1, title: 'Server Side Rendered Post', content: 'This content was generated on the server.' },
    { id: 2, title: 'Another SSR Post', content: 'Using simulated headers: ' + JSON.stringify(pageContext.headers?.['user-agent'] || 'unknown') }
  ];

  return {
    pageContext: {
      pageProps: {
        posts
      }
    }
  };
};