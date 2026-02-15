# URL Shortener

A full-stack URL shortening service deployed on AWS with a Typescript Express API running on ECS Fargate backed by DynamoDBReact frontend served via CloudFront/S3 and .

## Quick Start

```bash
# Backend
cd url-shortener/backend
cp .env.example .env          # configure DYNAMODB_TABLE_NAME, API_KEY, etc.
npm install
npm run dev                    # starts on :3000

# Frontend
cd url-shortener/frontend
npm install
npm run dev                    # starts on :5173, proxies /api to :3000
```

Run both services together with Docker Compose from `url-shortener/`:

```bash
docker-compose up
```

## Architecture

```
                         ┌─────────────────────────────────────────────────┐
                         │                  CloudFront                     │
                         │              (CDN + routing)                    │
                         └────┬──────────────────┬────────────────────────┘
                              │                  │
                              │ /api/*           │ static assets &
                              │ /:shortCode      │ SPA fallback
                              │                  │
                         ┌────▼────┐       ┌─────▼─────┐
              ┌──────┐   │   ALB   │       │  S3 (OAC) │
  WAF ────────┤ Rate │   │         │       │           │
  (managed    │ limit│   └────┬────┘       └───────────┘
   rules)     └──────┘        │              React + Vite
                         ┌────▼──────────┐   Tailwind CSS
                         │  ECS Fargate  │
                         │  (Express 5)  │
                         │               │
                         │  ┌──────────┐ │
                         │  │ Helmet   │ │
                         │  │ Rate-lim │ │
                         │  │ x-api-key│ │
                         │  └──────────┘ │
                         └──┬─────────┬──┘
                            │         │
                    ┌───────▼──┐  ┌───▼──────────┐
                    │ DynamoDB │  │ Redis        │
                    │ (on-dem) │  │ (prod/stg)   │
                    │          │  └──────────────┘
                    │ PK: shortCode
                    │ GSI: longUrl
                    └──────────┘
```

**Frontend** -- React 19 SPA built with Vite and Tailwind CSS. Provides a form for shortening URLs, displays results with QR codes, and tracks click stats. Served as static assets from S3 via CloudFront with Origin Access Control.

**Backend** -- Express 5 API on ECS Fargate behind an ALB. Three main routes: `POST /api/urls` (create), `GET /api/urls/:shortCode` (stats), and `GET /:shortCode` (302 redirect). Authenticated via `x-api-key` header backed by Secrets Manager. Short codes are 7-character SHA-256 hashes with collision retry. Helmet for security headers, express-rate-limit per endpoint.

**Persistence** -- DynamoDB in on-demand mode with `shortCode` as partition key and a `longUrl` GSI for deduplication. TTL on `expiresAt` for automatic link expiry. Optional ElastiCache Redis in staging/production for caching.

**Edge & Security** -- CloudFront routes static assets to S3 and API/redirect traffic to the ALB. A WAF WebACL applies AWS Managed Rules (Common Rule Set, Known Bad Inputs) and IP-based rate limiting. The backend additionally validates URLs against malicious protocols (`javascript:`, `data:`, `file:`).

**Observability** (staging/production) -- CloudWatch alarms for ALB errors/latency, ECS CPU/memory, DynamoDB throttling, and SQS DLQ depth. Auto-generated CloudWatch dashboard. X-Ray tracing in production via sidecar container. SNS alarm notifications.

## Infrastructure

Terraform modules live in `shared-infrastructure/modules/` and are consumed by per-service configs:

```
shared-infrastructure/
  actions/                    # CI composite actions (terraform-quality-check, terraform-deploy)
  modules/                    # dynamodb, ecs-fargate-service, elasticache-redis, sqs-queue,
                              # cloudwatch-alarms, cloudwatch-dashboard, ecr-repository, sns-topic, ...
url-shortener/
  backend/terraform/          # ECS Fargate, DynamoDB, ECR, ALB, optional Redis/SQS/monitoring
  frontend/terraform/         # S3, CloudFront, WAF, OAC
```

Each component has `config/development.tfvars`, `staging.tfvars`, and `production.tfvars` with matching backend state configs.

## Testing

```bash
# Backend unit + integration tests
cd url-shortener/backend
npm test              # run all tests
npm run test:coverage # with coverage report
```

Frontend linting and build verification:

```bash
cd url-shortener/frontend
npm run lint
npm run build
```
