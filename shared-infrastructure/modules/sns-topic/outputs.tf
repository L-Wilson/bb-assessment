output "topic_arn" {
  description = "SNS topic ARN"
  value       = aws_sns_topic.this.arn
}

output "topic_name" {
  description = "SNS topic name"
  value       = aws_sns_topic.this.name
}

output "topic_id" {
  description = "SNS topic ID"
  value       = aws_sns_topic.this.id
}

output "publish_policy_json" {
  description = "IAM policy JSON for publishing to topic"
  value = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sns:Publish"]
      Resource = [aws_sns_topic.this.arn]
    }]
  })
}
