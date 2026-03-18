import { redirect } from 'vike/abort';
import type { PageContextServer } from '@/renderer/types';

export const guard = async (pageContext: PageContextServer) => {
  // Check if user is logged in
  // Usually user state comes from pageContext which we populated earlier
  // Since we don't have real auth yet, we check headers or mocked user
  const user = pageContext.user;

  if (!user) {
    throw redirect('/auth/login');
  }
};