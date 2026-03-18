// src/renderer/types.ts
export type PageProps = Record<string, unknown>;
export type Page = (pageProps: PageProps) => React.ReactElement;

export type PageContextServer = {
  Page: Page;
  pageProps?: PageProps;
  urlPathname: string;
  exports: {
    documentProps?: {
      title?: string;
      description?: string;
    };
  };
  headers?: Record<string, string>;
  user?: {
    name: string;
    email: string;
  } | null;
}

export type PageContextClient = {
  Page: Page;
  pageProps?: PageProps;
  user?: {
    name: string;
    email: string;
  } | null;
}

export type PageContext = PageContextServer | PageContextClient;