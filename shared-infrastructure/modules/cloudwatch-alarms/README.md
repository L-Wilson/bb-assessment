# cloudwatch-alarms

Terraform module that creates CloudWatch metric alarms for common AWS services. Each alarm group can be independently enabled, allowing selective monitoring per environment.

## Features

- **ALB Alarms** -- 5xx errors, 4xx errors, p99 latency, unhealthy host count
- **ECS Alarms** -- CPU utilization, memory utilization, running task count
- **DynamoDB Alarms** -- Read throttle events, write throttle events, system errors
- **ElastiCache Alarms** -- Redis CPU, memory usage, evictions
- **SQS Alarms** -- Oldest message age, dead-letter queue message count

All alarms send notifications to a configurable SNS topic.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `alarm_name_prefix` | Prefix for all alarm names | `string` | -- | yes |
| `sns_topic_arn` | SNS topic ARN for notifications | `string` | -- | yes |
| `tags` | Tags to apply to all alarms | `map(string)` | `{}` | no |
| `alb_alarms_enabled` | Enable ALB alarms | `bool` | `false` | no |
| `alb_arn_suffix` | ARN suffix of the ALB | `string` | `null` | no |
| `target_group_arn_suffix` | ARN suffix of the target group | `string` | `null` | no |
| `alb_5xx_threshold` | ALB 5xx error count threshold | `number` | `10` | no |
| `alb_4xx_threshold` | ALB 4xx error count threshold | `number` | `100` | no |
| `alb_latency_threshold_ms` | ALB p99 latency threshold (ms) | `number` | `1000` | no |
| `alb_unhealthy_host_threshold` | Unhealthy host count threshold | `number` | `1` | no |
| `ecs_alarms_enabled` | Enable ECS alarms | `bool` | `false` | no |
| `ecs_cluster_name` | ECS cluster name | `string` | `null` | no |
| `ecs_service_name` | ECS service name | `string` | `null` | no |
| `ecs_cpu_threshold` | ECS CPU utilization threshold (%) | `number` | `80` | no |
| `ecs_memory_threshold` | ECS memory utilization threshold (%) | `number` | `80` | no |
| `ecs_running_task_threshold` | Minimum running task count | `number` | `1` | no |
| `dynamodb_alarms_enabled` | Enable DynamoDB alarms | `bool` | `false` | no |
| `dynamodb_table_name` | DynamoDB table name | `string` | `null` | no |
| `dynamodb_read_throttle_threshold` | Read throttle event threshold | `number` | `1` | no |
| `dynamodb_write_throttle_threshold` | Write throttle event threshold | `number` | `1` | no |
| `dynamodb_system_errors_threshold` | System error threshold | `number` | `1` | no |
| `elasticache_alarms_enabled` | Enable ElastiCache alarms | `bool` | `false` | no |
| `elasticache_cluster_id` | ElastiCache cluster ID | `string` | `null` | no |
| `elasticache_cpu_threshold` | Redis CPU threshold (%) | `number` | `75` | no |
| `elasticache_memory_threshold` | Redis memory threshold (%) | `number` | `80` | no |
| `elasticache_evictions_threshold` | Redis eviction count threshold | `number` | `100` | no |
| `sqs_alarms_enabled` | Enable SQS alarms | `bool` | `false` | no |
| `sqs_queue_name` | SQS queue name | `string` | `null` | no |
| `sqs_dlq_name` | SQS dead-letter queue name | `string` | `null` | no |
| `sqs_message_age_threshold` | Oldest message age threshold (s) | `number` | `300` | no |
| `sqs_dlq_messages_threshold` | DLQ message count threshold | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| `alarm_arns` | Map of alarm names to ARNs |
| `alarm_names` | List of all created alarm names |

## Usage

```hcl
module "alarms" {
  source = "../modules/cloudwatch-alarms"

  alarm_name_prefix = "myapp-prod"
  sns_topic_arn     = aws_sns_topic.alerts.arn

  alb_alarms_enabled     = true
  alb_arn_suffix         = module.alb.arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffixes[0]

  ecs_alarms_enabled = true
  ecs_cluster_name   = module.ecs.cluster_name
  ecs_service_name   = module.ecs.service_name

  dynamodb_alarms_enabled = true
  dynamodb_table_name     = module.dynamodb.table_name

  elasticache_alarms_enabled = true
  elasticache_cluster_id     = module.redis.cluster_id

  sqs_alarms_enabled = true
  sqs_queue_name     = module.sqs.queue_name
  sqs_dlq_name       = module.sqs.dlq_name

  tags = {
    Environment = "prod"
    Project     = "myapp"
  }
}
```
