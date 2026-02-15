variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "display_name" {
  description = "Display name for the SNS topic"
  type        = string
  default     = ""
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for SNS topic encryption"
  type        = string
  default     = null
}

variable "email_subscriptions" {
  description = "List of email addresses to subscribe to the topic"
  type        = list(string)
  default     = []
}

variable "https_subscriptions" {
  description = "List of HTTPS endpoint subscriptions"
  type = list(object({
    endpoint             = string
    raw_message_delivery = optional(bool, false)
  }))
  default = []
}

variable "sqs_subscriptions" {
  description = "List of SQS queue subscriptions"
  type = list(object({
    queue_arn            = string
    raw_message_delivery = optional(bool, false)
  }))
  default = []
}

variable "lambda_subscriptions" {
  description = "List of Lambda function ARNs to subscribe to the topic"
  type        = list(string)
  default     = []
}

variable "allow_cloudwatch_alarms" {
  description = "Whether to allow CloudWatch Alarms to publish to this topic"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the SNS topic"
  type        = map(string)
}
