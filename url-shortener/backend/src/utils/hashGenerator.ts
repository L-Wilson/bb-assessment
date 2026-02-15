import crypto from 'crypto';

const SHORT_CODE_LENGTH = 7;

export function generateShortCode(url: string, salt: number = 0): string {
  const input = salt > 0 ? `${url}:${salt}` : url;
  const hash = crypto.createHash('sha256').update(input).digest('hex');
  return hash.substring(0, SHORT_CODE_LENGTH);
}
