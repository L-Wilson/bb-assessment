# URL Shortener API

A production-ready URL shortener service built with TypeScript, Express, and DynamoDB. Designed for deployment on AWS infrastructure.

## Tech Stack

- **Runtime**: Node.js 20, TypeScript
- **Framework**: Express.js
- **Database**: Amazon DynamoDB (DynamoDB Local for development)
- **Containerization**: Docker & Docker Compose
- **Testing**: Jest, Supertest

## Quick Start

### With Docker Compose (recommended)

```bash
docker-compose up --build
```

This starts:
- **API server** on `http://localhost:3000`
- **DynamoDB Local** on `http://localhost:8000`
- **Init container** that creates the DynamoDB table automatically

### Local Development (without Docker)

1. Copy environment variables:
   ```bash
   cp .env.example .env
   ```

2. Start DynamoDB Local (requires Docker):
   ```bash
   docker run -p 8000:8000 amazon/dynamodb-local
   ```

3. Create the table:
   ```bash
   npx ts-node scripts/init-dynamodb.ts
   ```

4. Start the dev server:
   ```bash
   npm run dev
   ```

## API Documentation

Interactive OpenAPI docs are available at:

- `http://localhost:3000/docs` (Swagger UI)
- `http://localhost:3000/openapi.json` (raw OpenAPI spec)

To test authenticated `/api/*` endpoints in Swagger UI, click **Authorize** and set the `x-api-key` value (for local Docker Compose: `dev-api-key-12345`).

### Shorten a URL

```bash
curl -X POST http://localhost:3000/api/urls \
  -H "Content-Type: application/json" \
  -H "x-api-key: dev-api-key-12345" \
  -d '{"longUrl": "https://example.com/very/long/path"}'
```

Response (201):
```json
{
  "shortCode": "abc1234",
  "shortUrl": "http://localhost:3000/abc1234",
  "longUrl": "https://example.com/very/long/path",
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

### Redirect (public)

```bash
curl -L http://localhost:3000/abc1234
```

Returns a 302 redirect to the original URL.

### Get URL Details

```bash
curl http://localhost:3000/api/urls/abc1234 \
  -H "x-api-key: dev-api-key-12345"
```

Response (200):
```json
{
  "shortCode": "abc1234",
  "longUrl": "https://example.com/very/long/path",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "clickCount": 5
}
```

### Health Check

```bash
curl http://localhost:3000/health
```

Response (200):
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "database": "connected"
}
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `NODE_ENV` | `development` | Environment mode |
| `PORT` | `3000` | Server port |
| `API_KEY` | - | API key for authenticated endpoints |
| `BASE_URL` | `http://localhost:3000` | Base URL for generated short URLs |
| `LOG_LEVEL` | `info` | Log level (debug, info, warn, error) |
| `RATE_LIMIT_WINDOW_MS` | `900000` | Rate limit window in milliseconds |
| `RATE_LIMIT_MAX_POST` | `100` | Max POST requests per window per IP |
| `RATE_LIMIT_MAX_GET` | `1000` | Max GET requests per window per IP |
| `DYNAMODB_ENDPOINT` | - | DynamoDB endpoint (set for local dev, omit for AWS) |
| `DYNAMODB_TABLE_NAME` | `urls` | DynamoDB table name |
| `AWS_REGION` | `eu-central-1` | AWS region |

## Testing

```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Watch mode
npm run test:watch
```

## Architecture Decisions

- **Why DynamoDB**: Serverless scaling with pay-per-request pricing. The simple key-value access pattern (lookup by short code) is a perfect fit for DynamoDB's strengths. Global Tables enable multi-region replication when needed.

- **Why Repository Pattern**: Decouples business logic from the persistence layer, enabling easy testing with in-memory mocks and the ability to swap implementations (e.g., PostgreSQL) without changing service code.

- **Why 302 vs 301**: 302 (temporary) redirects ensure browsers always hit our server, enabling accurate click tracking. 301 (permanent) redirects get cached by browsers, making analytics unreliable.

- **Why Hash-based Short Codes**: SHA-256 hashing produces deterministic, stateless short codes. No coordination or sequence counter needed, which simplifies distributed deployment. Collision handling via salted rehashing provides reliability.

## Future Enhancements

- Redis caching layer for hot URLs
- Async analytics pipeline with SQS/Lambda
- Multi-region replication with DynamoDB Global Tables
- Custom vanity short codes
- URL expiration/TTL support
- Rate limiting with Redis (distributed)
