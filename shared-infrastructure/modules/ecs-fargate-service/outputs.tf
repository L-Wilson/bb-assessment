output "service_arn" {
  description = "ECS service ARN"
  value       = aws_ecs_service.this.id
}

output "service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.this.name
}

output "task_definition_arn" {
  description = "Task definition ARN"
  value       = aws_ecs_task_definition.this.arn
}

output "task_role_arn" {
  description = "Task IAM role ARN"
  value       = aws_iam_role.task.arn
}

output "execution_role_arn" {
  description = "Execution IAM role ARN"
  value       = aws_iam_role.execution.arn
}

output "security_group_id" {
  description = "Task security group ID"
  value       = aws_security_group.task.id
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = var.create_alb ? aws_lb.this[0].dns_name : null
}

output "alb_arn" {
  description = "ALB ARN"
  value       = var.create_alb ? aws_lb.this[0].arn : null
}

output "target_group_arn" {
  description = "Target group ARN"
  value       = var.create_alb ? aws_lb_target_group.this[0].arn : null
}
