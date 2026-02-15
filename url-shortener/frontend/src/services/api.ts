import type { ShortenResponse } from '../types';

const API_BASE_URL = import.meta.env.VITE_API_URL || '';

export async function shortenUrl(longUrl: string, apiKey: string): Promise<ShortenResponse> {
  const res = await fetch(`${API_BASE_URL}/api/urls`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
    },
    body: JSON.stringify({ longUrl }),
  });

  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body.message || body.error || `Request failed (${res.status})`);
  }

  return res.json();
}

export async function getUrlStats(shortCode: string, apiKey: string): Promise<ShortenResponse> {
  const res = await fetch(`${API_BASE_URL}/api/urls/${shortCode}`, {
    headers: { 'x-api-key': apiKey },
  });

  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body.message || body.error || `Request failed (${res.status})`);
  }

  return res.json();
}
