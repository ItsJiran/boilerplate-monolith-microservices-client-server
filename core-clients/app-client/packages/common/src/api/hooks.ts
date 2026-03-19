// src/api/hooks.ts
import { useState, useCallback } from 'react';
import { api } from './client';
import { AxiosError, AxiosRequestConfig } from 'axios';

// Generic hook to fetch data
export function useFetch<T>(url: string, config?: AxiosRequestConfig) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<AxiosError | null>(null);

  const fetch = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await api.get<T>(url, config);
      setData(response);
      return response;
    } catch (err: any) {
      setError(err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, [url, JSON.stringify(config)]);

  return { data, loading, error, fetch };
}