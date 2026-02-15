variable "cluster_id" {
  description = "Unique identifier for the ElastiCache replication group"
  type        = string
}

variable "description" {
  description = "Human-readable description of the replication group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ElastiCache cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ElastiCache subnet group"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "List of security group IDs allowed to access the Redis cluster"
  type        = list(string)
}

variable "node_type" {
  description = "ElastiCache node instance type"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "Number of cache nodes in the replication group"
  type        = number
  default     = 1
}

variable "engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.0"
}

variable "port" {
  description = "Port number for Redis"
  type        = number
  default     = 6379
}

variable "parameter_group_family" {
  description = "ElastiCache parameter group family"
  type        = string
  default     = "redis7"
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover (requires num_cache_nodes >= 2)"
  type        = bool
  default     = false
}

variable "multi_az_enabled" {
  description = "Enable Multi-AZ support (requires automatic_failover_enabled = true)"
  type        = bool
  default     = false
}

variable "at_rest_encryption_enabled" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Enable in-transit encryption"
  type        = bool
  default     = true
}

variable "auth_token" {
  description = "Auth token for Redis AUTH (requires transit_encryption_enabled = true)"
  type        = string
  sensitive   = true
  default     = null
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for at-rest encryption"
  type        = string
  default     = null
}

variable "snapshot_retention_limit" {
  description = "Number of days to retain automatic snapshots (0 to disable)"
  type        = number
  default     = 7
}

variable "snapshot_window" {
  description = "Daily time range during which automated backups are created (UTC)"
  type        = string
  default     = "03:00-05:00"
}

variable "maintenance_window" {
  description = "Weekly time range for maintenance operations (UTC)"
  type        = string
  default     = "sun:05:00-sun:07:00"
}

variable "apply_immediately" {
  description = "Whether changes should be applied immediately or during the next maintenance window"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}
