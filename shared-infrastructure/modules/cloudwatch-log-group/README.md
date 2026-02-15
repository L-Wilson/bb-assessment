# cloudwatch-log-group

Terraform module that creates an AWS CloudWatch Log Group with configurable retention and optional KMS encryption.

## Usage

```hcl
module "app_logs" {
  source = "./modules/cloudwatch-log-group"

  log_group_name    = "/app/my-service"
  retention_in_days = 90
  kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/example-key-id"

  tags = {
    Environment = "production"
    Service     = "my-service"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `log_group_name` | Log group name | `string` | n/a | yes |
| `retention_in_days` | Log retention period in days | `number` | `30` | no |
| `kms_key_arn` | KMS key ARN for encryption | `string` | `null` | no |
| `tags` | Tags to apply | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `log_group_arn` | CloudWatch Log Group ARN |
| `log_group_name` | CloudWatch Log Group name |
