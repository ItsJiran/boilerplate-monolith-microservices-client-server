import { AxiosInstance, AxiosRequestConfig } from 'axios';
export { default as axios, api } from './client';
export * from './hooks';
export * from './query-client';
export * from '@tanstack/react-query';

// Type helper
export type APIResponse<T> = {
  data: T;
  message?: string;
  status: number;
}