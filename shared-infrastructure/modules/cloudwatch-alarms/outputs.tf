locals {
  all_alarms = merge(
    { for k, v in aws_cloudwatch_metric_alarm.alb_5xx : "alb-5xx" => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.alb_4xx : "alb-4xx" => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.alb_latency : "alb-latency" => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.alb_unhealthy_hosts : "alb-unhealthy-hosts" => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.ecs_cpu : "ecs-cpu" => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.ecs_memory : "ecs-memory" => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.ecs_running_tasks : "ecs-running-tasks" => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.dynamodb_read_throttle : "dynamodb-read-throttle" => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.dynamodb_write_throttle : "dynamodb-write-throttle" => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.dynamodb_system_errors : "dynamodb-system-errors" => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.elasticache_cpu : "redis-cpu" => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.elasticache_memory : "redis-memory" => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.elasticache_evictions : "redis-evictions" => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.sqs_message_age : "sqs-message-age" => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.sqs_dlq_messages : "sqs-dlq-messages" => v.arn },
  )
}

output "alarm_arns" {
  description = "Map of alarm names to ARNs"
  value       = local.all_alarms
}

output "alarm_names" {
  description = "List of all alarm names"
  value       = keys(local.all_alarms)
}
