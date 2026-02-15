# DynamoDB Terraform Module

Creates an AWS DynamoDB table with optional KMS encryption, point-in-time recovery, TTL, streams, and global secondary indexes. Outputs pre-built IAM policy documents for read, write, and read/write access.

## Usage

```hcl
module "orders_table" {
  source = "./modules/dynamodb"

  table_name = "orders"
  hash_key   = "customer_id"
  range_key  = "order_id"

  ttl_attribute  = "expires_at"
  stream_enabled = true

  global_secondary_indexes = [
    {
      name            = "status-index"
      hash_key        = "status"
      hash_key_type   = "S"
      range_key       = "created_at"
      range_key_type  = "S"
      projection_type = "ALL"
    }
  ]

  tags = {
    Environment = "production"
    Service     = "orders"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| table_name | Name of the DynamoDB table | string | - | yes |
| hash_key | Hash (partition) key for the table | string | - | yes |
| hash_key_type | Attribute type for the hash key (S, N, B) | string | `"S"` | no |
| range_key | Range (sort) key for the table | string | `null` | no |
| range_key_type | Attribute type for the range key (S, N, B) | string | `"S"` | no |
| billing_mode | PAY_PER_REQUEST or PROVISIONED | string | `"PAY_PER_REQUEST"` | no |
| enable_point_in_time_recovery | Enable point-in-time recovery | bool | `true` | no |
| enable_encryption | Enable server-side encryption with KMS CMK | bool | `true` | no |
| kms_key_arn | ARN of existing KMS key; if null a new key is created | string | `null` | no |
| ttl_attribute | TTL attribute name; null to disable | string | `null` | no |
| stream_enabled | Enable DynamoDB Streams | bool | `false` | no |
| stream_view_type | Stream view type (NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES, KEYS_ONLY) | string | `"NEW_AND_OLD_IMAGES"` | no |
| global_secondary_indexes | List of GSI definitions | list(object) | `[]` | no |
| tags | Tags to apply to all resources | map(string) | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| table_arn | DynamoDB table ARN |
| table_name | DynamoDB table name |
| table_id | DynamoDB table ID |
| kms_key_arn | KMS key ARN used for encryption |
| stream_arn | DynamoDB stream ARN (null if streams disabled) |
| read_policy_json | IAM policy JSON for read-only access |
| write_policy_json | IAM policy JSON for write access |
| read_write_policy_json | IAM policy JSON for read/write access |
