// src/pages/ssr-test/+data.ts
import { PageContextServer } from '../../renderer/types';

export const data = async (pageContext: PageContextServer) => {
  // Simulate fetching data from Laravel API
  // Using simulated fetch for now as backend might not be up 
  
  // Real usage with @repo/common:
  // import { api } from '@repo/common/api';
  // const posts = await api.get('/posts', { headers: pageContext.headers });

  const posts = [
    { id: 1, title: 'Hello World', content: 'This is fetched from SSR with spoofed headers!' },
    { id: 2, title: 'Another Post', content: 'Vike is cool.' }
  ];

  // We can pass the pageContext headers to verify they are present in backend calls
  console.log('SSR Request Headers (Spoofed):', pageContext.headers);

  return posts;
};