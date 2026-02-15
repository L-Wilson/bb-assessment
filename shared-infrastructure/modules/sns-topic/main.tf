data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_sns_topic" "this" {
  name              = var.topic_name
  display_name      = var.display_name != "" ? var.display_name : null
  kms_master_key_id = var.kms_key_arn

  tags = var.tags
}

# Allow CloudWatch Alarms to publish
resource "aws_sns_topic_policy" "this" {
  count = var.allow_cloudwatch_alarms ? 1 : 0

  arn = aws_sns_topic.this.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudWatchAlarms"
        Effect    = "Allow"
        Principal = { Service = "cloudwatch.amazonaws.com" }
        Action    = "SNS:Publish"
        Resource  = aws_sns_topic.this.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid       = "AllowAccountPublish"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = ["SNS:Publish", "SNS:Subscribe", "SNS:GetTopicAttributes"]
        Resource  = aws_sns_topic.this.arn
      }
    ]
  })
}

# Email subscriptions
resource "aws_sns_topic_subscription" "email" {
  for_each = toset(var.email_subscriptions)

  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = each.value
}

# HTTPS subscriptions
resource "aws_sns_topic_subscription" "https" {
  for_each = { for idx, sub in var.https_subscriptions : idx => sub }

  topic_arn            = aws_sns_topic.this.arn
  protocol             = "https"
  endpoint             = each.value.endpoint
  raw_message_delivery = each.value.raw_message_delivery
}

# SQS subscriptions
resource "aws_sns_topic_subscription" "sqs" {
  for_each = { for idx, sub in var.sqs_subscriptions : idx => sub }

  topic_arn            = aws_sns_topic.this.arn
  protocol             = "sqs"
  endpoint             = each.value.queue_arn
  raw_message_delivery = each.value.raw_message_delivery
}

# Lambda subscriptions
resource "aws_sns_topic_subscription" "lambda" {
  for_each = toset(var.lambda_subscriptions)

  topic_arn = aws_sns_topic.this.arn
  protocol  = "lambda"
  endpoint  = each.value
}
