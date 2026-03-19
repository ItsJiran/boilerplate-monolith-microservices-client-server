import { createServerApi } from '@repo/common/api';
import { PageContextServer } from '../../renderer/types';

export const data = async (pageContext: PageContextServer) => {
  try {
    const serverApi = createServerApi(pageContext.headers ?? {});
    const payload = await serverApi.get('/api/user');
    const user = payload?.data ?? payload;

    return [
      {
        id: 1,
        title: 'SSR Header Forwarding Active',
        content: user?.email
          ? `Authenticated as ${user.email} from Laravel during SSR.`
          : 'Session headers forwarded, but no authenticated user found.',
      },
      {
        id: 2,
        title: 'User Agent',
        content: String(pageContext.headers?.['user-agent'] ?? 'unknown'),
      },
    ];
  } catch {
    return [
      {
        id: 1,
        title: 'SSR Fallback',
        content: 'Backend unavailable. SSR fallback data is shown.',
      },
      {
        id: 2,
        title: 'User Agent',
        content: String(pageContext.headers?.['user-agent'] ?? 'unknown'),
      },
    ];
  }
};