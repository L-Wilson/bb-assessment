import { UrlService, InvalidUrlError, CollisionError } from '../../../src/services/urlService';
import { MockUrlRepository } from '../../mocks/mockUrlRepository';

describe('UrlService', () => {
  let service: UrlService;
  let repository: MockUrlRepository;

  beforeEach(() => {
    repository = new MockUrlRepository();
    service = new UrlService(repository);
  });

  describe('shortenUrl', () => {
    it('should create a short URL for a valid long URL', async () => {
      const result = await service.shortenUrl('https://example.com/long/path');
      expect(result.shortCode).toHaveLength(7);
      expect(result.longUrl).toBe('https://example.com/long/path');
      expect(result.clickCount).toBe(0);
      expect(result.createdAt).toBeInstanceOf(Date);
    });

    it('should return existing entity for duplicate URL', async () => {
      const first = await service.shortenUrl('https://example.com/dup');
      const second = await service.shortenUrl('https://example.com/dup');
      expect(first.shortCode).toBe(second.shortCode);
    });

    it('should throw InvalidUrlError for invalid URLs', async () => {
      await expect(service.shortenUrl('not-a-url')).rejects.toThrow(InvalidUrlError);
    });

    it('should throw InvalidUrlError for malicious URLs', async () => {
      await expect(service.shortenUrl('javascript:alert(1)')).rejects.toThrow(InvalidUrlError);
    });

    it('should handle collisions by retrying with salt', async () => {
      // Seed a collision: same short code but different long URL
      const { generateShortCode } = require('../../../src/utils/hashGenerator');
      const collisionCode = generateShortCode('https://example.com/new-url', 0);
      repository.seed([{
        shortCode: collisionCode,
        longUrl: 'https://different-url.com',
        createdAt: new Date(),
        clickCount: 0,
      }]);

      const result = await service.shortenUrl('https://example.com/new-url');
      expect(result.shortCode).toHaveLength(7);
      expect(result.shortCode).not.toBe(collisionCode);
      expect(result.longUrl).toBe('https://example.com/new-url');
    });

    it('should throw CollisionError after max retries', async () => {
      // Seed collisions for all 5 retry attempts
      const { generateShortCode } = require('../../../src/utils/hashGenerator');
      const url = 'https://example.com/collide';
      for (let i = 0; i < 5; i++) {
        const code = generateShortCode(url, i);
        repository.seed([{
          shortCode: code,
          longUrl: `https://other-${i}.com`,
          createdAt: new Date(),
          clickCount: 0,
        }]);
      }

      await expect(service.shortenUrl(url)).rejects.toThrow(CollisionError);
    });
  });

  describe('resolveUrl', () => {
    it('should return the URL entity for a valid short code', async () => {
      await service.shortenUrl('https://example.com/resolve');
      const created = await repository.findByLongUrl('https://example.com/resolve');
      const result = await service.resolveUrl(created!.shortCode);
      expect(result).not.toBeNull();
      expect(result!.longUrl).toBe('https://example.com/resolve');
    });

    it('should return null for non-existent short code', async () => {
      const result = await service.resolveUrl('noexist');
      expect(result).toBeNull();
    });

    it('should increment click count', async () => {
      await service.shortenUrl('https://example.com/clicks');
      const created = await repository.findByLongUrl('https://example.com/clicks');
      await service.resolveUrl(created!.shortCode);
      // Allow the fire-and-forget to complete
      await new Promise((r) => setTimeout(r, 10));
      const updated = await repository.findByShortCode(created!.shortCode);
      expect(updated!.clickCount).toBe(1);
    });
  });
});
