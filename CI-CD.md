# CI/CD Runbook

## Overview
Primary entrypoint is `.github/workflows/pipeline.yaml`.

Trigger behavior:
- `pull_request` to `main`: validation only
- `push` to `main`: CI + progressive promotion

`pipeline.yaml` calls reusable workflows:
- `.github/workflows/backend-infra-pr.yaml`
- `.github/workflows/frontend-infra-pr.yaml`
- `.github/workflows/backend-app-ci.yaml`
- `.github/workflows/frontend-app-ci.yaml`
- `.github/workflows/backend-infra-deploy.yaml`
- `.github/workflows/frontend-infra-deploy.yaml`
- `.github/workflows/backend-app-deploy.yaml`
- `.github/workflows/frontend-app-deploy.yaml`

## Path-Based Job Skipping
The pipeline starts with `detect_changes` (using `dorny/paths-filter`) and sets four flags:
- `backend_app`
- `frontend_app`
- `backend_infra`
- `frontend_infra`

Only jobs for changed areas run. Unaffected service jobs are skipped.

Change scopes:
- `backend_app`: `url-shortener/backend/**` + backend app workflow files
- `frontend_app`: `url-shortener/frontend/**` + frontend app workflow files
- `backend_infra`: `url-shortener/backend/terraform/**`, `shared-infrastructure/**`, shared infra action files, backend infra workflow files
- `frontend_infra`: `url-shortener/frontend/terraform/**`, `shared-infrastructure/**`, shared infra action files, frontend infra workflow files

## Required GitHub Setup
1. Repo variable:
- `AWS_GITHUB_ROLE`

2. GitHub Environments:
- `development`
- `staging`
- `production`

3. Environment protections:
- Required reviewers on `production`

4. Branch protection:
- Protect `main` with required checks and review rules

## PR Flow (`pull_request` -> `main`)
Runs validation only for changed areas:
1. Infra CI (backend/frontend as needed)
- Terraform quality checks
- Terraform plan for `development` (fork PRs skip plan)

2. App CI (backend/frontend as needed)
- Lint/tests/audit
- Backend: Docker build + Trivy scan
- Frontend: static build (`npm run build`)
- No deploy on PR

No deploy jobs run on PR.

## Main Flow (`push` -> `main`)
Runs only for changed areas, in sequence:
1. Infra CI
2. App CI
- Backend: builds/scans and pushes image to ECR (`development` repo), emits immutable image tag `${GITHUB_SHA::12}`
- Frontend: builds static assets
3. `CI_Changesets` (placeholder) when app code changed
4. Deploy `development` infra/app (changed services only)
5. `Integration_Tests_Dev` gate (placeholder)
6. Deploy `staging` infra/app (changed services only)
7. `Integration_Tests_Staging` gate (placeholder)
8. Deploy `production` infra/app (changed services only)

Promotion order is enforced via `needs:`.

## Image Promotion Model
- Backend: CI builds one image tag per commit and deploy workflows promote that exact tag by copying ECR manifest across repos (`development` -> `staging` -> `production`).
- Frontend: deploy workflow rebuilds static assets and deploys to environment S3 bucket, then invalidates CloudFront cache.