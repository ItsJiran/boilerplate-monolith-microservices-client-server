// src/api/client.ts
import axios, { AxiosHeaders, AxiosInstance, AxiosRequestConfig } from 'axios';
import { useAuthStore } from '../store';

type RequestHeaders = Record<string, string | undefined>;

export type CreateApiClientOptions = {
  baseURL?: string;
  serverHeaders?: RequestHeaders;
  withCredentials?: boolean;
  onUnauthorized?: () => void;
};

function normalizeHeaders(input?: RequestHeaders): RequestHeaders {
  if (!input) return {};

  const normalized: RequestHeaders = {};
  for (const [key, value] of Object.entries(input)) {
    normalized[key.toLowerCase()] = value;
  }
  return normalized;
}

function resolveBaseURL(override?: string): string {
  return (
    override ||
    process.env.VITE_API_URL ||
    process.env.API_URL ||
    process.env.APP_API_URL ||
    'http://localhost:8000'
  );
}

export function createApiClient(options: CreateApiClientOptions = {}): AxiosInstance {
  const serverHeaders = normalizeHeaders(options.serverHeaders);

  const instance = axios.create({
    baseURL: resolveBaseURL(options.baseURL),
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json',
    },
    withCredentials: options.withCredentials ?? true,
  });

  instance.interceptors.request.use(
    (config) => {
      const headers = AxiosHeaders.from(config.headers || {});

      if (!headers.has('Authorization')) {
        const token = useAuthStore.getState().token;
        if (token) {
          headers.set('Authorization', `Bearer ${token}`);
        }
      }

      const forwardedCookie = serverHeaders.cookie;
      if (!headers.has('Cookie') && forwardedCookie) {
        headers.set('Cookie', forwardedCookie);
      }

      const forwardedAuth = serverHeaders.authorization;
      if (!headers.has('Authorization') && forwardedAuth) {
        headers.set('Authorization', forwardedAuth);
      }

      config.headers = headers;
      return config;
    },
    (error) => Promise.reject(error)
  );

  instance.interceptors.response.use(
    (response) => response,
    (error) => {
      if (error.response?.status === 401) {
        useAuthStore.getState().logout();
        options.onUnauthorized?.();
      }
      return Promise.reject(error);
    }
  );

  return instance;
}

export function createServerApi(serverHeaders: RequestHeaders, baseURL?: string): AxiosInstance {
  return createApiClient({
    baseURL,
    serverHeaders,
    withCredentials: true,
  });
}

const client = createApiClient();

export const api = {
  get: <T>(url: string, config?: AxiosRequestConfig) => client.get<T>(url, config).then((res) => res.data),
  post: <T>(url: string, data?: unknown, config?: AxiosRequestConfig) =>
    client.post<T>(url, data, config).then((res) => res.data),
  put: <T>(url: string, data?: unknown, config?: AxiosRequestConfig) =>
    client.put<T>(url, data, config).then((res) => res.data),
  patch: <T>(url: string, data?: unknown, config?: AxiosRequestConfig) =>
    client.patch<T>(url, data, config).then((res) => res.data),
  delete: <T>(url: string, config?: AxiosRequestConfig) => client.delete<T>(url, config).then((res) => res.data),
};

export default client;