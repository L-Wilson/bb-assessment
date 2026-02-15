const MALICIOUS_PATTERNS = [
  /^javascript:/i,
  /^data:/i,
  /^file:/i,
  /^vbscript:/i,
];

export function isValidUrl(url: string): boolean {
  if (!url || typeof url !== 'string') return false;

  for (const pattern of MALICIOUS_PATTERNS) {
    if (pattern.test(url.trim())) return false;
  }

  try {
    const parsed = new URL(url);
    return ['http:', 'https:'].includes(parsed.protocol);
  } catch {
    return false;
  }
}

export function sanitizeUrl(url: string): string {
  return url.trim();
}
