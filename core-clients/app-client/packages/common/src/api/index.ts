export { default as axios, api, createApiClient, createServerApi } from './client';
export * from './hooks';
export * from './query-client';
export * from '@tanstack/react-query';

// Type helper
export type APIResponse<T> = {
  data: T;
  message?: string;
  status: number;
}