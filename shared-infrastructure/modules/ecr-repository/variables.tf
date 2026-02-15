variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "IMMUTABLE"
}

variable "scan_on_push" {
  description = "Whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "The encryption type for the repository (AES256 or KMS)"
  type        = string
  default     = "KMS"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type must be either AES256 or KMS."
  }
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used for encryption (required when encryption_type is KMS)"
  type        = string
  default     = null
}

variable "lifecycle_policy_max_image_count" {
  description = "Maximum number of tagged images to retain"
  type        = number
  default     = 30
}

variable "lifecycle_policy_untagged_days" {
  description = "Number of days after which untagged images are removed"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to the ECR repository"
  type        = map(string)
  default     = {}
}
