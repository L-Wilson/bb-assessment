# URL Shortener

A full-stack URL shortening service on AWS with a TypeScript/Express API running on ECS Fargate and backed by DynamoDB, plus a React frontend served via CloudFront and S3.

## Approach & AI usage

Hi all 👋 Thanks for taking the time to review my assignment. I approached this task as a discussion-starter rather than trying to get something 100% production-ready. I spent most of the time understanding the problem, outlining the architecture and tradeoffs, and organizing the repository and infrastructure so decisions are easy to review in follow-up conversation.

I used AI tools to accelerate drafting, scaffolding, and iteration once the direction was clear. The implementation reflects my decision-making, but there are still loose ends / parts in need of polishing before this would be ready for release. Looking forward to chatting about it all :)

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
docker compose up --build
```

With Docker Compose, the frontend is available at `http://localhost:8080`.

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
              ┌──────┐   │   ALB   │       │  S3       │
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
                    ┌───────▼──┐  ┌───▼────────────────────┐
                    │ DynamoDB │  │ Redis (coming soon)    │
                    │ (on-dem) │  │                        │
                    │          │  └──────────────┘
                    │ PK: shortCode
                    │ GSI: longUrl
                    └──────────┘
```

**Backend** -- Express 5 API on ECS Fargate behind an ALB. Three main routes: `POST /api/urls` (create), `GET /api/urls/:shortCode` (stats), and `GET /:shortCode` (302 redirect). Authenticated via `x-api-key` header backed by Secrets Manager. Short codes are 7-character SHA-256 hashes with collision retry. Helmet for security headers, express-rate-limit per endpoint.

**Persistence** -- DynamoDB in on-demand mode with `shortCode` as partition key and a `longUrl` GSI for deduplication. TTL on `expiresAt` for automatic link expiry. Optional ElastiCache Redis in staging/production for caching.

**Future Analytics/Caching Path** -- Planned flow: publish redirect events to SQS, aggregate click velocity/top short codes, and use Redis as a hot-key cache in front of DynamoDB for frequently requested redirects. This is intended to reduce read latency and DynamoDB load under traffic spikes.

**Edge & Security** -- CloudFront routes static assets to S3 and API/redirect traffic to the ALB. A WAF WebACL applies AWS Managed Rules (Common Rule Set, Known Bad Inputs) and IP-based rate limiting. The backend additionally validates URLs against malicious protocols (`javascript:`, `data:`, `file:`).

**Observability** (staging/production) -- CloudWatch alarms for ALB errors/latency, ECS CPU/memory, DynamoDB throttling, and SQS DLQ depth. Auto-generated CloudWatch dashboard. X-Ray tracing in production via sidecar container. SNS alarm notifications.

**Frontend** -- React SPA built with Vite and Tailwind CSS. Provides a form for shortening URLs, displays results with QR codes, and tracks click stats. Served as static assets from S3 via CloudFront with Origin Access Control.

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
