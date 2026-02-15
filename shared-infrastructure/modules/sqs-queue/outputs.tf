output "queue_arn" {
  description = "SQS queue ARN"
  value       = aws_sqs_queue.this.arn
}

output "queue_url" {
  description = "SQS queue URL"
  value       = aws_sqs_queue.this.url
}

output "queue_name" {
  description = "SQS queue name"
  value       = aws_sqs_queue.this.name
}

output "dlq_arn" {
  description = "Dead letter queue ARN"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].arn : null
}

output "dlq_url" {
  description = "Dead letter queue URL"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].url : null
}

output "dlq_name" {
  description = "Dead letter queue name"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].name : null
}

output "send_message_policy_json" {
  description = "IAM policy JSON for sending messages"
  value = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sqs:SendMessage", "sqs:GetQueueUrl", "sqs:GetQueueAttributes"]
      Resource = [aws_sqs_queue.this.arn]
    }]
  })
}

output "receive_message_policy_json" {
  description = "IAM policy JSON for receiving messages"
  value = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueUrl",
        "sqs:GetQueueAttributes",
        "sqs:ChangeMessageVisibility",
      ]
      Resource = [aws_sqs_queue.this.arn]
    }]
  })
}

output "full_access_policy_json" {
  description = "IAM policy JSON for full queue access"
  value = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sqs:*"]
      Resource = compact([
        aws_sqs_queue.this.arn,
        var.create_dlq ? aws_sqs_queue.dlq[0].arn : "",
      ])
    }]
  })
}
