// src/renderer/+onRenderClient.tsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import { Layout } from '@/renderer/Layout';
import { PageContextProvider } from '@/renderer/usePageContext';
import type { PageContextClient } from '@/renderer/types';

export const onRenderClient = async (pageContext: PageContextClient) => {
  const { Page, pageProps } = pageContext;
  
  const rootElement = document.getElementById('root');
  if (!rootElement) throw new Error('Root element not found');

  const container = (
    <PageContextProvider pageContext={pageContext}>
      <Layout pageContext={pageContext}>
        <Page {...pageProps} />
      </Layout>
    </PageContextProvider>
  );

  ReactDOM.hydrateRoot(rootElement, container);
};