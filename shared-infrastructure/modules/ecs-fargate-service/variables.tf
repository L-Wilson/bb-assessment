###############################################################################
# Required Variables
###############################################################################

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the service will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "container_image" {
  description = "Docker image for the container (e.g. 123456789.dkr.ecr.us-east-1.amazonaws.com/my-app:latest)"
  type        = string
}

variable "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  type        = string
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
}

###############################################################################
# Container Configuration
###############################################################################

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 3000
}

variable "cpu" {
  description = "CPU units for the task (1 vCPU = 1024)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory in MiB for the task"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of running tasks"
  type        = number
  default     = 2
}

variable "environment_variables" {
  description = "List of environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "secrets" {
  description = "List of secrets to inject into the container from SSM or Secrets Manager"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "health_check_path" {
  description = "HTTP path for the container health check"
  type        = string
  default     = "/health"
}

###############################################################################
# Observability
###############################################################################

variable "enable_xray_tracing" {
  description = "Enable AWS X-Ray tracing sidecar container"
  type        = bool
  default     = true
}

###############################################################################
# Service Discovery
###############################################################################

variable "enable_service_discovery" {
  description = "Enable ECS Service Connect for service discovery"
  type        = bool
  default     = true
}

variable "ecs_namespace_arn" {
  description = "ARN of the ECS Service Connect namespace"
  type        = string
  default     = null
}

###############################################################################
# ALB Configuration
###############################################################################

variable "create_alb" {
  description = "Whether to create an Application Load Balancer for this service"
  type        = bool
  default     = true
}

variable "alb_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
  default     = []
}

variable "alb_certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS. When null, only HTTP listener is created."
  type        = string
  default     = null
}

variable "alb_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to access the ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

###############################################################################
# Auto Scaling
###############################################################################

variable "enable_autoscaling" {
  description = "Enable auto scaling for the ECS service"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks when auto scaling is enabled"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks when auto scaling is enabled"
  type        = number
  default     = 10
}

variable "autoscaling_cpu_target" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 70
}

###############################################################################
# IAM
###############################################################################

variable "task_role_policy_arns" {
  description = "List of IAM policy ARNs to attach to the task role"
  type        = list(string)
  default     = []
}

variable "task_role_policy_json" {
  description = "Inline IAM policy JSON to attach to the task role"
  type        = string
  default     = null
}

###############################################################################
# Tags
###############################################################################

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
