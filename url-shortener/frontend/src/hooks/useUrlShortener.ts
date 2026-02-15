import { useState, useCallback } from 'react';
import { shortenUrl, getUrlStats } from '../services/api';
import { useLocalStorage } from './useLocalStorage';
import type { ShortenResponse, RecentUrl } from '../types';

export function useUrlShortener() {
  const [result, setResult] = useState<ShortenResponse | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [apiKey, setApiKey] = useLocalStorage('url-shortener-api-key', '');
  const [recentUrls, setRecentUrls] = useLocalStorage<RecentUrl[]>('url-shortener-recent', []);

  const shorten = useCallback(
    async (longUrl: string) => {
      setLoading(true);
      setError(null);
      try {
        const data = await shortenUrl(longUrl, apiKey);
        setResult(data);
        setRecentUrls((prev) => {
          const filtered = prev.filter((u) => u.shortCode !== data.shortCode);
          return [
            { shortCode: data.shortCode, shortUrl: data.shortUrl, longUrl: data.longUrl, createdAt: data.createdAt },
            ...filtered,
          ].slice(0, 10);
        });
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Something went wrong');
      } finally {
        setLoading(false);
      }
    },
    [apiKey, setRecentUrls],
  );

  const refreshStats = useCallback(async () => {
    if (!result) return;
    try {
      const data = await getUrlStats(result.shortCode, apiKey);
      setResult(data);
    } catch {
      // silently fail on refresh
    }
  }, [result, apiKey]);

  const reset = useCallback(() => {
    setResult(null);
    setError(null);
  }, []);

  const clearHistory = useCallback(() => {
    setRecentUrls([]);
  }, [setRecentUrls]);

  return {
    result,
    loading,
    error,
    apiKey,
    setApiKey,
    recentUrls,
    shorten,
    refreshStats,
    reset,
    clearHistory,
  };
}
