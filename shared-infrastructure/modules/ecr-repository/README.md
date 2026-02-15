# ecr-repository

Terraform module for creating an AWS ECR repository with image scanning, encryption, and lifecycle policies.

## Usage

```hcl
module "ecr" {
  source = "./modules/ecr-repository"

  repository_name = "my-app"
  encryption_type = "KMS"
  kms_key_arn     = "arn:aws:kms:us-east-1:123456789012:key/example-key-id"

  lifecycle_policy_max_image_count = 30
  lifecycle_policy_untagged_days   = 7

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| repository_name | Name of the ECR repository | `string` | n/a | yes |
| image_tag_mutability | Tag mutability setting (MUTABLE or IMMUTABLE) | `string` | `"IMMUTABLE"` | no |
| scan_on_push | Whether images are scanned after being pushed | `bool` | `true` | no |
| encryption_type | Encryption type (AES256 or KMS) | `string` | `"KMS"` | no |
| kms_key_arn | ARN of the KMS key for encryption | `string` | `null` | no |
| lifecycle_policy_max_image_count | Maximum number of tagged images to retain | `number` | `30` | no |
| lifecycle_policy_untagged_days | Days after which untagged images are removed | `number` | `7` | no |
| tags | Tags to apply to the ECR repository | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| repository_url | ECR repository URL |
| repository_arn | ECR repository ARN |
| repository_name | ECR repository name |
