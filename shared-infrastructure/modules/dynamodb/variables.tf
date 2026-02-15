variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "hash_key" {
  description = "Hash (partition) key for the table"
  type        = string
}

variable "hash_key_type" {
  description = "Attribute type for the hash key (S = String, N = Number, B = Binary)"
  type        = string
  default     = "S"
}

variable "range_key" {
  description = "Range (sort) key for the table"
  type        = string
  default     = null
}

variable "range_key_type" {
  description = "Attribute type for the range key (S = String, N = Number, B = Binary)"
  type        = string
  default     = "S"
}

variable "billing_mode" {
  description = "Billing mode for the table (PAY_PER_REQUEST or PROVISIONED)"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode must be either PAY_PER_REQUEST or PROVISIONED."
  }
}

variable "enable_point_in_time_recovery" {
  description = "Whether to enable point-in-time recovery"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Whether to enable server-side encryption with a KMS CMK"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of an existing KMS key for encryption. If null and encryption is enabled, a new key is created."
  type        = string
  default     = null
}

variable "ttl_attribute" {
  description = "Name of the TTL attribute. Set to null to disable TTL."
  type        = string
  default     = null
}

variable "stream_enabled" {
  description = "Whether to enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream view type when streams are enabled (NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES, KEYS_ONLY)"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"

  validation {
    condition     = contains(["NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES", "KEYS_ONLY"], var.stream_view_type)
    error_message = "stream_view_type must be one of: NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES, KEYS_ONLY."
  }
}

variable "global_secondary_indexes" {
  description = "List of global secondary indexes to create on the table"
  type = list(object({
    name               = string
    hash_key           = string
    hash_key_type      = string
    range_key          = optional(string)
    range_key_type     = optional(string, "S")
    projection_type    = optional(string, "ALL")
    non_key_attributes = optional(list(string))
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
