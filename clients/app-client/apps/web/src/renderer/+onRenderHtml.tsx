// src/renderer/+onRenderHtml.tsx
import ReactDOMServer from 'react-dom/server';
import React from 'react';
import { escapeInject, dangerouslySkipEscape } from 'vike/server';
import type { PageContextServer } from '@/renderer/types';
import { Layout } from '@/renderer/Layout';
import { PageContextProvider } from '@/renderer/usePageContext';

export const onRenderHtml = async (pageContext: PageContextServer) => {
  const { Page, pageProps } = pageContext;
  
  // Render the Page component inside the Layout
  const pageHtml = ReactDOMServer.renderToString(
    <PageContextProvider pageContext={pageContext}>
      <Layout pageContext={pageContext}>
        <Page {...pageProps} />
      </Layout>
    </PageContextProvider>
  );

  // See https://vike.dev/head
  const { documentProps } = pageContext.exports;
  const title = (documentProps && documentProps.title) || 'My Vike App';
  const desc = (documentProps && documentProps.description) || 'App using Vike';

  const documentHtml = escapeInject`<!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8" />
        <link rel="icon" type="image/svg+xml" href="/vite.svg" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta name="description" content="${desc}" />
        <title>${title}</title>
      </head>
      <body>
        <div id="root">${dangerouslySkipEscape(pageHtml)}</div>
      </body>
    </html>`;

  return {
    documentHtml,
    pageContext: {
      // We can add some `pageContext` here, which is useful if we want to pass data to the client-side.
      // E.g. `user` info if we fetched it on the server.
    }
  };
};