###############################################################################
# General
###############################################################################
variable "alarm_name_prefix" {
  description = "Prefix for all alarm names (e.g. project-env)"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all alarms"
  type        = map(string)
  default     = {}
}

###############################################################################
# ALB Alarms
###############################################################################
variable "alb_alarms_enabled" {
  description = "Whether to create ALB alarms"
  type        = bool
  default     = false
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB"
  type        = string
  default     = null
}

variable "target_group_arn_suffix" {
  description = "ARN suffix of the target group (required for unhealthy host alarm)"
  type        = string
  default     = null
}

variable "alb_5xx_threshold" {
  description = "Threshold for ALB 5xx error count"
  type        = number
  default     = 10
}

variable "alb_4xx_threshold" {
  description = "Threshold for ALB 4xx error count"
  type        = number
  default     = 100
}

variable "alb_latency_threshold_ms" {
  description = "Threshold for ALB p99 latency in milliseconds"
  type        = number
  default     = 1000
}

variable "alb_unhealthy_host_threshold" {
  description = "Threshold for unhealthy host count"
  type        = number
  default     = 1
}

###############################################################################
# ECS Alarms
###############################################################################
variable "ecs_alarms_enabled" {
  description = "Whether to create ECS alarms"
  type        = bool
  default     = false
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = null
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
  default     = null
}

variable "ecs_cpu_threshold" {
  description = "Threshold for ECS CPU utilization percentage"
  type        = number
  default     = 80
}

variable "ecs_memory_threshold" {
  description = "Threshold for ECS memory utilization percentage"
  type        = number
  default     = 80
}

variable "ecs_running_task_threshold" {
  description = "Minimum number of running tasks before alarming"
  type        = number
  default     = 1
}

###############################################################################
# DynamoDB Alarms
###############################################################################
variable "dynamodb_alarms_enabled" {
  description = "Whether to create DynamoDB alarms"
  type        = bool
  default     = false
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = null
}

variable "dynamodb_read_throttle_threshold" {
  description = "Threshold for DynamoDB read throttle events"
  type        = number
  default     = 1
}

variable "dynamodb_write_throttle_threshold" {
  description = "Threshold for DynamoDB write throttle events"
  type        = number
  default     = 1
}

variable "dynamodb_system_errors_threshold" {
  description = "Threshold for DynamoDB system errors"
  type        = number
  default     = 1
}

###############################################################################
# ElastiCache Alarms
###############################################################################
variable "elasticache_alarms_enabled" {
  description = "Whether to create ElastiCache alarms"
  type        = bool
  default     = false
}

variable "elasticache_cluster_id" {
  description = "ID of the ElastiCache cluster"
  type        = string
  default     = null
}

variable "elasticache_cpu_threshold" {
  description = "Threshold for Redis CPU utilization percentage"
  type        = number
  default     = 75
}

variable "elasticache_memory_threshold" {
  description = "Threshold for Redis memory usage percentage"
  type        = number
  default     = 80
}

variable "elasticache_evictions_threshold" {
  description = "Threshold for Redis eviction count"
  type        = number
  default     = 100
}

###############################################################################
# SQS Alarms
###############################################################################
variable "sqs_alarms_enabled" {
  description = "Whether to create SQS alarms"
  type        = bool
  default     = false
}

variable "sqs_queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = null
}

variable "sqs_dlq_name" {
  description = "Name of the SQS dead-letter queue (required for DLQ alarm)"
  type        = string
  default     = null
}

variable "sqs_message_age_threshold" {
  description = "Threshold for oldest message age in seconds"
  type        = number
  default     = 300
}

variable "sqs_dlq_messages_threshold" {
  description = "Threshold for number of messages in DLQ"
  type        = number
  default     = 1
}
