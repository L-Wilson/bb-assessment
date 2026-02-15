output "ecr_repository_url" {
  description = "ECR repository URL for pushing images"
  value       = module.ecr.repository_url
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb.table_name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  value       = module.dynamodb.table_arn
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs_service.service_name
}

output "alb_dns_name" {
  description = "ALB DNS name for accessing the service"
  value       = module.ecs_service.alb_dns_name
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = module.log_group.log_group_name
}

output "api_key_secret_arn" {
  description = "Secrets Manager ARN for the API key"
  value       = aws_secretsmanager_secret.api_key.arn
}

output "alb_arn" {
  description = "ALB ARN"
  value       = module.ecs_service.alb_arn
}

output "redis_primary_endpoint" {
  description = "Redis primary endpoint address"
  value       = var.enable_redis ? module.redis[0].primary_endpoint_address : null
}

output "sqs_queue_url" {
  description = "SQS queue URL"
  value       = var.enable_sqs ? module.sqs[0].queue_url : null
}

output "alarm_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  value       = var.enable_monitoring ? module.alarm_topic[0].topic_arn : null
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = var.enable_monitoring ? module.dashboard[0].dashboard_name : null
}
