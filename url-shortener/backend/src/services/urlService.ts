import { UrlRepository } from '../repositories/urlRepository';
import { UrlEntity } from '../types';
import { generateShortCode } from '../utils/hashGenerator';
import { isValidUrl, sanitizeUrl } from '../utils/urlValidator';
import { config } from '../config';
import { logger } from '../utils/logger';

const MAX_RETRIES = 5;

export class UrlService {
  constructor(private repository: UrlRepository) {}

  async shortenUrl(longUrl: string): Promise<UrlEntity> {
    const sanitized = sanitizeUrl(longUrl);

    if (!isValidUrl(sanitized)) {
      throw new InvalidUrlError('Invalid or malicious URL');
    }

    // Check if URL already shortened (deduplication)
    const existing = await this.repository.findByLongUrl(sanitized);
    if (existing) {
      logger.info('URL already shortened, returning existing', { shortCode: existing.shortCode });
      return existing;
    }

    // Generate short code with collision handling
    for (let attempt = 0; attempt < MAX_RETRIES; attempt++) {
      const shortCode = generateShortCode(sanitized, attempt);

      const collision = await this.repository.findByShortCode(shortCode);
      if (collision) {
        if (collision.longUrl === sanitized) {
          return collision;
        }
        logger.warn('Hash collision detected, retrying', { attempt, shortCode });
        continue;
      }

      const entity: UrlEntity = {
        shortCode,
        longUrl: sanitized,
        createdAt: new Date(),
        clickCount: 0,
      };

      try {
        return await this.repository.save(entity);
      } catch (error: unknown) {
        // Handle race condition where another request saved the same shortCode
        if (error && typeof error === 'object' && 'name' in error && error.name === 'ConditionalCheckFailedException') {
          logger.warn('Race condition on save, retrying', { attempt, shortCode });
          continue;
        }
        throw error;
      }
    }

    throw new CollisionError('Failed to generate unique short code after maximum retries');
  }

  async resolveUrl(shortCode: string): Promise<UrlEntity | null> {
    const entity = await this.repository.findByShortCode(shortCode);
    if (!entity) return null;

    // Fire and forget click count increment
    this.repository.incrementClickCount(shortCode).catch((err) => {
      logger.error('Failed to increment click count', { shortCode, error: String(err) });
    });

    return entity;
  }

  async getUrlDetails(shortCode: string): Promise<UrlEntity | null> {
    return this.repository.findByShortCode(shortCode);
  }

  async healthCheck(): Promise<boolean> {
    return this.repository.healthCheck();
  }
}

export class InvalidUrlError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'InvalidUrlError';
  }
}

export class CollisionError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'CollisionError';
  }
}
