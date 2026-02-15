# sqs-queue

Terraform module that creates an AWS SQS queue with an optional dead letter queue (DLQ). Supports both standard and FIFO queues, configurable encryption (SQS managed SSE or customer-managed KMS), and outputs ready-to-use IAM policy JSON documents for send, receive, and full access patterns.

## Usage

```hcl
module "order_events" {
  source = "../../shared-infrastructure/modules/sqs-queue"

  queue_name                 = "order-events"
  visibility_timeout_seconds = 60
  max_receive_count          = 5

  tags = {
    Environment = "production"
    Service     = "orders"
  }
}

# FIFO queue example
module "payment_processing" {
  source = "../../shared-infrastructure/modules/sqs-queue"

  queue_name                  = "payment-processing"
  fifo_queue                  = true
  content_based_deduplication = true

  tags = {
    Environment = "production"
    Service     = "payments"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| queue_name | Name of the SQS queue | `string` | n/a | yes |
| fifo_queue | Whether to create a FIFO queue | `bool` | `false` | no |
| content_based_deduplication | Enable content-based deduplication for FIFO queues | `bool` | `false` | no |
| visibility_timeout_seconds | The visibility timeout for the queue (seconds) | `number` | `30` | no |
| message_retention_seconds | The number of seconds SQS retains a message | `number` | `1209600` | no |
| max_message_size | Maximum message size in bytes | `number` | `262144` | no |
| delay_seconds | Delivery delay for all messages in the queue (seconds) | `number` | `0` | no |
| receive_wait_time_seconds | Long polling wait time (seconds) | `number` | `10` | no |
| create_dlq | Whether to create a dead letter queue | `bool` | `true` | no |
| max_receive_count | Receives before a message is moved to the DLQ | `number` | `3` | no |
| dlq_message_retention_seconds | Message retention for the DLQ (seconds) | `number` | `1209600` | no |
| kms_key_arn | KMS key ARN for encryption; if null, SQS managed SSE is used | `string` | `null` | no |
| kms_data_key_reuse_period_seconds | KMS data key reuse period (seconds) | `number` | `300` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| queue_arn | SQS queue ARN |
| queue_url | SQS queue URL |
| queue_name | SQS queue name |
| dlq_arn | Dead letter queue ARN (null if DLQ not created) |
| dlq_url | Dead letter queue URL (null if DLQ not created) |
| dlq_name | Dead letter queue name (null if DLQ not created) |
| send_message_policy_json | IAM policy JSON for sending messages |
| receive_message_policy_json | IAM policy JSON for receiving messages |
| full_access_policy_json | IAM policy JSON for full queue access |
