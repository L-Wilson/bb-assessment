# naming-and-tags

Terraform module that provides standardized resource naming conventions and tag sets for consistent infrastructure labeling across environments.

## Purpose

This module generates consistent identifiers (long, short, and globally unique hash-suffixed forms) and a standardized set of tags for all resources. It ensures every resource is traceable back to its project, team, environment, and source repository.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project` | Project name | `string` | — | yes |
| `app_name` | Application name | `string` | — | yes |
| `environment` | Environment (`development`, `staging`, `production`) | `string` | — | yes |
| `team` | Owning team | `string` | — | yes |
| `criticality` | Business criticality (`low`, `medium`, `high`, `critical`) | `string` | `"medium"` | no |
| `data_classification` | Data classification (`public`, `internal`, `confidential`, `restricted`) | `string` | `"internal"` | no |
| `contains_pii` | Whether resource contains PII | `bool` | `false` | no |
| `source_repository` | Source code repository URL | `string` | — | yes |
| `additional_tags` | Additional tags to merge into the standard set | `map(string)` | `{}` | no |

## Outputs

| Name | Description | Example |
|------|-------------|---------|
| `id_long` | `{project}-{app_name}-{environment}` | `urlshortener-production` |
| `id_short` | `{app_short}-{env_short}` | `urls-prd` |
| `id_hash` | `{id_short}-{random_hash}` | `urls-prd-a1b2c3` |
| `tags` | Standardized tags map | *(see below)* |
| `environment_short` | Short environment code | `prd` |
| `app_short` | Short application name code | `urls` |
| `project` | Project name passthrough | `bb-assessment` |

## Usage

```hcl
module "naming" {
  source = "../../shared-infrastructure/modules/naming-and-tags"

  project            = "bb-assessment"
  app_name           = "urlshortener"
  environment        = "production"
  team               = "platform"
  source_repository  = "https://github.com/bb-assessment/url-shortener"
}

# Use in resource naming
resource "aws_dynamodb_table" "this" {
  name = "${module.naming.id_long}-urls"
  tags = module.naming.tags
}
```
