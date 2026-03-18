// src/pages/ssr-test/+Page.tsx
import React from 'react';
// import { useData } from 'vike-react/useData'; // Using pageProps instead now

export function Page({ posts }: { posts: any[] }) {
  // const data = useData<any>(); // Assuming type

  return (
    <>
      <h1>SSR Data Fetching</h1>
      <p>This data was fetched on the server and passed as props:</p>
      <ul>
        {posts.map(post => (
            <li key={post.id}>
                <strong>{post.title}</strong>: {post.content}
            </li>
        ))}
      </ul>
      <pre>{JSON.stringify(posts, null, 2)}</pre>
    </>
  );
}