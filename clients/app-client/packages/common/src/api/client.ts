// src/api/client.ts
import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import { useAuthStore } from '../store';

const API_URL = process.env.NEXT_PUBLIC_API_URL || import.meta.env.VITE_API_URL || 'http://localhost:8000';

const client: AxiosInstance = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
  withCredentials: true,
});

// Request Interceptor: Attach Token
client.interceptors.request.use(
  (config) => {
    // Access zustand store state directly without hook
    const token = useAuthStore.getState().token;
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response Interceptor: Handle 401
client.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Clear auth on server logout or token expiry
      useAuthStore.getState().logout();
      // Optional: Redirect logic if needed at app level (usually handled by auth state change in App.tsx)
    }
    return Promise.reject(error);
  }
);

// Helper for type-safe requests
export const api = {
  get: <T>(url: string, config?: AxiosRequestConfig) => 
    client.get<T>(url, config).then(res => res.data),
    
  post: <T>(url: string, data?: any, config?: AxiosRequestConfig) => 
    client.post<T>(url, data, config).then(res => res.data),
    
  put: <T>(url: string, data?: any, config?: AxiosRequestConfig) => 
    client.put<T>(url, data, config).then(res => res.data),
    
  patch: <T>(url: string, data?: any, config?: AxiosRequestConfig) => 
    client.patch<T>(url, data, config).then(res => res.data),
    
  delete: <T>(url: string, config?: AxiosRequestConfig) => 
    client.delete<T>(url, config).then(res => res.data),
};

export default client;