variable "project" {
  description = "Project name"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Environment (development, staging, production)"
  type        = string

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}

variable "team" {
  description = "Owning team"
  type        = string
}

variable "criticality" {
  description = "Business criticality (low, medium, high, critical)"
  type        = string
  default     = "medium"

  validation {
    condition     = contains(["low", "medium", "high", "critical"], var.criticality)
    error_message = "Criticality must be one of: low, medium, high, critical."
  }
}

variable "data_classification" {
  description = "Data classification (public, internal, confidential, restricted)"
  type        = string
  default     = "internal"

  validation {
    condition     = contains(["public", "internal", "confidential", "restricted"], var.data_classification)
    error_message = "Data classification must be one of: public, internal, confidential, restricted."
  }
}

variable "contains_pii" {
  description = "Whether resource contains PII"
  type        = bool
  default     = false
}

variable "source_repository" {
  description = "Source code repository URL"
  type        = string
}

variable "additional_tags" {
  description = "Additional tags to merge"
  type        = map(string)
  default     = {}
}
