variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
}

variable "fifo_queue" {
  description = "Whether to create a FIFO queue"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO queues"
  type        = bool
  default     = false
}

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue (seconds)"
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message"
  type        = number
  default     = 1209600
}

variable "max_message_size" {
  description = "The limit of how many bytes a message can contain (bytes)"
  type        = number
  default     = 262144
}

variable "delay_seconds" {
  description = "The time in seconds that the delivery of all messages in the queue will be delayed"
  type        = number
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive (long polling)"
  type        = number
  default     = 10
}

variable "create_dlq" {
  description = "Whether to create a dead letter queue"
  type        = bool
  default     = true
}

variable "max_receive_count" {
  description = "The number of times a message is received before being moved to the DLQ"
  type        = number
  default     = 3
}

variable "dlq_message_retention_seconds" {
  description = "The number of seconds the DLQ retains a message"
  type        = number
  default     = 1209600
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for server-side encryption. If null, SQS managed SSE is used"
  type        = string
  default     = null
}

variable "kms_data_key_reuse_period_seconds" {
  description = "The length of time for which Amazon SQS can reuse a data key to encrypt/decrypt messages"
  type        = number
  default     = 300
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
