variable "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  type        = string
}

variable "aws_region" {
  description = "AWS region for the dashboard widgets"
  type        = string
}

variable "service_name" {
  description = "Name of the service displayed in the dashboard title"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., development, staging, production) displayed in the dashboard title"
  type        = string
}

# CloudFront
variable "cloudfront_enabled" {
  description = "Whether to include CloudFront widgets in the dashboard"
  type        = bool
  default     = false
}

variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for metrics"
  type        = string
  default     = null
}

# ALB
variable "alb_enabled" {
  description = "Whether to include ALB widgets in the dashboard"
  type        = bool
  default     = false
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for metrics"
  type        = string
  default     = null
}

variable "target_group_arn_suffix" {
  description = "Target group ARN suffix for metrics"
  type        = string
  default     = null
}

# ECS
variable "ecs_enabled" {
  description = "Whether to include ECS widgets in the dashboard"
  type        = bool
  default     = false
}

variable "ecs_cluster_name" {
  description = "ECS cluster name for metrics"
  type        = string
  default     = null
}

variable "ecs_service_name" {
  description = "ECS service name for metrics"
  type        = string
  default     = null
}

# DynamoDB
variable "dynamodb_enabled" {
  description = "Whether to include DynamoDB widgets in the dashboard"
  type        = bool
  default     = false
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for metrics"
  type        = string
  default     = null
}

# ElastiCache
variable "elasticache_enabled" {
  description = "Whether to include ElastiCache (Redis) widgets in the dashboard"
  type        = bool
  default     = false
}

variable "elasticache_cluster_id" {
  description = "ElastiCache cluster ID for metrics"
  type        = string
  default     = null
}

# SQS
variable "sqs_enabled" {
  description = "Whether to include SQS widgets in the dashboard"
  type        = bool
  default     = false
}

variable "sqs_queue_name" {
  description = "SQS queue name for metrics"
  type        = string
  default     = null
}

# Logs
variable "log_group_name" {
  description = "CloudWatch Logs group name for the error log query widget"
  type        = string
  default     = null
}
