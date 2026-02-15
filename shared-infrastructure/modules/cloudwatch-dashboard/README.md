# CloudWatch Dashboard Module

Creates a CloudWatch dashboard with conditionally enabled widgets for monitoring AWS services. Each widget group can be independently toggled on or off, allowing a single dashboard definition to adapt to different service architectures.

## Features

The module supports the following widget types, each enabled via a boolean flag:

- **CloudFront** - Requests, error rates (4xx/5xx), cache hit rate, bytes downloaded
- **ALB** - Request count, p99 latency, HTTP status code breakdown (2xx/4xx/5xx)
- **ECS** - CPU and memory utilization, running task count (via Container Insights)
- **DynamoDB** - Consumed read/write capacity, request latency, throttle events
- **ElastiCache (Redis)** - Engine CPU, memory usage, cache hit rate, connections
- **SQS** - Messages sent/received, visible messages, oldest message age
- **Application Logs** - CloudWatch Logs Insights query for error-level log entries

A title text widget is always included at the top of the dashboard.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `dashboard_name` | Name of the CloudWatch dashboard | `string` | n/a | yes |
| `aws_region` | AWS region for the dashboard widgets | `string` | n/a | yes |
| `service_name` | Service name displayed in the dashboard title | `string` | n/a | yes |
| `environment` | Environment name displayed in the dashboard title | `string` | n/a | yes |
| `cloudfront_enabled` | Include CloudFront widgets | `bool` | `false` | no |
| `cloudfront_distribution_id` | CloudFront distribution ID | `string` | `null` | no |
| `alb_enabled` | Include ALB widgets | `bool` | `false` | no |
| `alb_arn_suffix` | ALB ARN suffix | `string` | `null` | no |
| `target_group_arn_suffix` | Target group ARN suffix | `string` | `null` | no |
| `ecs_enabled` | Include ECS widgets | `bool` | `false` | no |
| `ecs_cluster_name` | ECS cluster name | `string` | `null` | no |
| `ecs_service_name` | ECS service name | `string` | `null` | no |
| `dynamodb_enabled` | Include DynamoDB widgets | `bool` | `false` | no |
| `dynamodb_table_name` | DynamoDB table name | `string` | `null` | no |
| `elasticache_enabled` | Include ElastiCache widgets | `bool` | `false` | no |
| `elasticache_cluster_id` | ElastiCache cluster ID | `string` | `null` | no |
| `sqs_enabled` | Include SQS widgets | `bool` | `false` | no |
| `sqs_queue_name` | SQS queue name | `string` | `null` | no |
| `log_group_name` | CloudWatch Logs group name for the error log widget | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `dashboard_arn` | CloudWatch dashboard ARN |
| `dashboard_name` | CloudWatch dashboard name |

## Usage

```hcl
module "dashboard" {
  source = "./modules/cloudwatch-dashboard"

  dashboard_name = "url-shortener-prod"
  aws_region     = "us-east-1"
  service_name   = "URL Shortener"
  environment    = "prod"

  cloudfront_enabled         = true
  cloudfront_distribution_id = module.cdn.distribution_id

  alb_enabled    = true
  alb_arn_suffix = module.alb.arn_suffix

  ecs_enabled      = true
  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name

  dynamodb_enabled    = true
  dynamodb_table_name = module.dynamodb.table_name

  log_group_name = "/ecs/url-shortener-prod"
}
```
