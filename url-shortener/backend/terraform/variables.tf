###############################################################################
# General
###############################################################################

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "default"
}

variable "environment" {
  description = "Deployment environment (development, staging, production)"
  type        = string
}

###############################################################################
# ECS / Container
###############################################################################

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "cpu" {
  description = "Task CPU units"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Task memory (MB)"
  type        = number
  default     = 512
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 3000
}

###############################################################################
# Auto Scaling
###############################################################################

variable "enable_autoscaling" {
  description = "Enable ECS auto scaling"
  type        = bool
  default     = false
}

variable "autoscaling_min" {
  description = "Minimum task count"
  type        = number
  default     = 1
}

variable "autoscaling_max" {
  description = "Maximum task count"
  type        = number
  default     = 10
}

###############################################################################
# Logging
###############################################################################

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

###############################################################################
# Redis (ElastiCache)
###############################################################################

variable "enable_redis" {
  description = "Enable ElastiCache Redis cluster"
  type        = bool
  default     = false
}

variable "redis_node_type" {
  description = "ElastiCache node instance type"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_num_cache_nodes" {
  description = "Number of cache nodes"
  type        = number
  default     = 1
}

variable "redis_automatic_failover" {
  description = "Enable automatic failover (requires num_cache_nodes >= 2)"
  type        = bool
  default     = false
}

variable "redis_multi_az" {
  description = "Enable Multi-AZ support"
  type        = bool
  default     = false
}

###############################################################################
# SQS
###############################################################################

variable "enable_sqs" {
  description = "Enable SQS queue for async processing"
  type        = bool
  default     = false
}

###############################################################################
# Monitoring
###############################################################################

variable "enable_monitoring" {
  description = "Enable CloudWatch alarms and dashboard"
  type        = bool
  default     = false
}

variable "alert_email" {
  description = "Email address for alarm notifications"
  type        = string
  default     = ""
}
