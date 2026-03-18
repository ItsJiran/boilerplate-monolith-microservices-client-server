// src/renderer/usePageContext.tsx
import React, { useContext } from 'react';
import type { PageContext } from '@/renderer/types';

const PageContext = React.createContext<PageContext | undefined>(undefined);

export function PageContextProvider({ pageContext, children }: { pageContext: PageContext, children: React.ReactNode }) {
  return (
    <PageContext.Provider value={pageContext}>
      {children}
    </PageContext.Provider>
  );
}

export function usePageContext() {
  const pageContext = useContext(PageContext);
  if (!pageContext) {
    throw new Error('usePageContext must be used within a PageContextProvider');
  }
  return pageContext;
}