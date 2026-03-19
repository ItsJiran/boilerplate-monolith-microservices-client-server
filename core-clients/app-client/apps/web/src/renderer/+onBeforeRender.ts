import { PageContextServer } from '@/renderer/types';
import { createServerApi } from '@repo/common/api';

export const onBeforeRender = async (pageContext: PageContextServer) => {
  const { headers } = pageContext;
  let user = null;

  if (headers?.cookie || headers?.authorization) {
    try {
      const serverApi = createServerApi(headers);
      const payload = await serverApi.get('/api/user');

      if (payload?.data) {
        user = payload.data;
      } else {
        user = payload;
      }
    } catch {
      user = null;
    }
  }

  return {
    pageContext: {
      user,
    },
  };
};