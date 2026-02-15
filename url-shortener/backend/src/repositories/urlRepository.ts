import { UrlEntity } from '../types';

export interface UrlRepository {
  save(url: UrlEntity): Promise<UrlEntity>;
  findByShortCode(shortCode: string): Promise<UrlEntity | null>;
  findByLongUrl(longUrl: string): Promise<UrlEntity | null>;
  incrementClickCount(shortCode: string): Promise<void>;
  healthCheck(): Promise<boolean>;
}
