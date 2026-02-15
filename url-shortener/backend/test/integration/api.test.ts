import request from 'supertest';
import { createApp } from '../../src/app';
import { MockUrlRepository } from '../mocks/mockUrlRepository';

// Mock config for tests
jest.mock('../../src/config', () => ({
  config: {
    nodeEnv: 'test',
    port: 3000,
    apiKey: 'test-api-key',
    baseUrl: 'http://localhost:3000',
    logLevel: 'error',
    rateLimitWindowMs: 900000,
    rateLimitMaxPost: 100,
    rateLimitMaxGet: 1000,
    dynamodb: {
      endpoint: 'http://localhost:8000',
      tableName: 'urls',
      region: 'eu-central-1',
    },
  },
}));

describe('API Integration Tests', () => {
  let app: ReturnType<typeof createApp>;
  let repository: MockUrlRepository;

  beforeEach(() => {
    repository = new MockUrlRepository();
    app = createApp(repository);
  });

  describe('POST /api/urls', () => {
    it('should create a short URL and return 201', async () => {
      const res = await request(app)
        .post('/api/urls')
        .set('x-api-key', 'test-api-key')
        .send({ longUrl: 'https://example.com/long/path' });

      expect(res.status).toBe(201);
      expect(res.body.shortCode).toHaveLength(7);
      expect(res.body.shortUrl).toContain(res.body.shortCode);
      expect(res.body.longUrl).toBe('https://example.com/long/path');
      expect(res.body.createdAt).toBeDefined();
    });

    it('should return 401 without API key', async () => {
      const res = await request(app)
        .post('/api/urls')
        .send({ longUrl: 'https://example.com' });

      expect(res.status).toBe(401);
      expect(res.body.error).toBe('API key is required');
    });

    it('should return 403 with invalid API key', async () => {
      const res = await request(app)
        .post('/api/urls')
        .set('x-api-key', 'wrong-key')
        .send({ longUrl: 'https://example.com' });

      expect(res.status).toBe(403);
      expect(res.body.error).toBe('Invalid API key');
    });

    it('should return 400 for invalid URL', async () => {
      const res = await request(app)
        .post('/api/urls')
        .set('x-api-key', 'test-api-key')
        .send({ longUrl: 'not-a-url' });

      expect(res.status).toBe(400);
    });

    it('should return 400 when longUrl is missing', async () => {
      const res = await request(app)
        .post('/api/urls')
        .set('x-api-key', 'test-api-key')
        .send({});

      expect(res.status).toBe(400);
      expect(res.body.error).toBe('longUrl is required');
    });

    it('should return 400 for malicious URL', async () => {
      const res = await request(app)
        .post('/api/urls')
        .set('x-api-key', 'test-api-key')
        .send({ longUrl: 'javascript:alert(1)' });

      expect(res.status).toBe(400);
    });
  });

  describe('GET /:shortCode', () => {
    it('should redirect with 302 for existing short code', async () => {
      // First create a URL
      const createRes = await request(app)
        .post('/api/urls')
        .set('x-api-key', 'test-api-key')
        .send({ longUrl: 'https://example.com/redirect-test' });

      const { shortCode } = createRes.body;

      const res = await request(app)
        .get(`/${shortCode}`)
        .redirects(0);

      expect(res.status).toBe(302);
      expect(res.headers.location).toBe('https://example.com/redirect-test');
    });

    it('should return 404 for non-existent short code', async () => {
      const res = await request(app).get('/noexist');
      expect(res.status).toBe(404);
    });
  });

  describe('GET /api/urls/:shortCode', () => {
    it('should return URL details with auth', async () => {
      const createRes = await request(app)
        .post('/api/urls')
        .set('x-api-key', 'test-api-key')
        .send({ longUrl: 'https://example.com/details-test' });

      const { shortCode } = createRes.body;

      const res = await request(app)
        .get(`/api/urls/${shortCode}`)
        .set('x-api-key', 'test-api-key');

      expect(res.status).toBe(200);
      expect(res.body.shortCode).toBe(shortCode);
      expect(res.body.longUrl).toBe('https://example.com/details-test');
      expect(res.body.clickCount).toBe(0);
    });
  });

  describe('GET /health', () => {
    it('should return healthy status', async () => {
      const res = await request(app).get('/health');

      expect(res.status).toBe(200);
      expect(res.body.status).toBe('healthy');
      expect(res.body.timestamp).toBeDefined();
      expect(res.body.database).toBe('connected');
    });
  });
});
