import { UrlRepository } from '../../src/repositories/urlRepository';
import { UrlEntity } from '../../src/types';

export class MockUrlRepository implements UrlRepository {
  private store: Map<string, UrlEntity> = new Map();

  async save(url: UrlEntity): Promise<UrlEntity> {
    if (this.store.has(url.shortCode)) {
      const error = new Error('Conditional check failed');
      error.name = 'ConditionalCheckFailedException';
      throw error;
    }
    this.store.set(url.shortCode, { ...url });
    return url;
  }

  async findByShortCode(shortCode: string): Promise<UrlEntity | null> {
    return this.store.get(shortCode) ?? null;
  }

  async findByLongUrl(longUrl: string): Promise<UrlEntity | null> {
    for (const entity of this.store.values()) {
      if (entity.longUrl === longUrl) return entity;
    }
    return null;
  }

  async incrementClickCount(shortCode: string): Promise<void> {
    const entity = this.store.get(shortCode);
    if (entity) {
      entity.clickCount += 1;
    }
  }

  async healthCheck(): Promise<boolean> {
    return true;
  }

  clear(): void {
    this.store.clear();
  }

  seed(entities: UrlEntity[]): void {
    for (const entity of entities) {
      this.store.set(entity.shortCode, { ...entity });
    }
  }
}
