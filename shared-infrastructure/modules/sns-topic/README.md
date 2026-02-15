# sns-topic

Terraform module for creating an AWS SNS topic with optional subscriptions (email, HTTPS, SQS, Lambda) and a CloudWatch Alarms publish policy.

## Usage

```hcl
module "alerts_topic" {
  source = "./modules/sns-topic"

  topic_name   = "my-app-alerts"
  display_name = "My App Alerts"
  kms_key_arn  = "arn:aws:kms:us-east-1:123456789012:key/example-key-id"

  email_subscriptions = ["oncall@example.com"]

  sqs_subscriptions = [
    {
      queue_arn            = "arn:aws:sqs:us-east-1:123456789012:my-queue"
      raw_message_delivery = true
    }
  ]

  allow_cloudwatch_alarms = true

  tags = {
    Environment = "production"
    Service     = "my-app"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| topic_name | Name of the SNS topic | `string` | n/a | yes |
| display_name | Display name for the SNS topic | `string` | `""` | no |
| kms_key_arn | ARN of the KMS key for encryption | `string` | `null` | no |
| email_subscriptions | List of email addresses to subscribe | `list(string)` | `[]` | no |
| https_subscriptions | List of HTTPS endpoint subscriptions | `list(object)` | `[]` | no |
| sqs_subscriptions | List of SQS queue subscriptions | `list(object)` | `[]` | no |
| lambda_subscriptions | List of Lambda function ARNs to subscribe | `list(string)` | `[]` | no |
| allow_cloudwatch_alarms | Allow CloudWatch Alarms to publish to the topic | `bool` | `true` | no |
| tags | Tags to apply to the SNS topic | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| topic_arn | SNS topic ARN |
| topic_name | SNS topic name |
| topic_id | SNS topic ID |
| publish_policy_json | IAM policy JSON for publishing to the topic |
