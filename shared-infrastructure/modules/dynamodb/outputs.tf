output "table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.this.arn
}

output "table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.this.name
}

output "table_id" {
  description = "DynamoDB table ID"
  value       = aws_dynamodb_table.this.id
}

output "kms_key_arn" {
  description = "KMS key ARN used for encryption"
  value       = local.kms_key_arn
}

output "stream_arn" {
  description = "DynamoDB stream ARN"
  value       = var.stream_enabled ? aws_dynamodb_table.this.stream_arn : null
}

output "read_policy_json" {
  description = "IAM policy JSON for read-only access"
  value = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect = "Allow"
          Action = [
            "dynamodb:GetItem",
            "dynamodb:BatchGetItem",
            "dynamodb:Query",
            "dynamodb:Scan",
          ]
          Resource = [
            aws_dynamodb_table.this.arn,
            "${aws_dynamodb_table.this.arn}/index/*",
          ]
        }
      ],
      local.kms_key_arn != null ? [
        {
          Effect = "Allow"
          Action = [
            "kms:Decrypt",
            "kms:DescribeKey",
          ]
          Resource = [local.kms_key_arn]
        }
      ] : []
    )
  })
}

output "write_policy_json" {
  description = "IAM policy JSON for write access"
  value = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect = "Allow"
          Action = [
            "dynamodb:PutItem",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem",
            "dynamodb:BatchWriteItem",
          ]
          Resource = [
            aws_dynamodb_table.this.arn,
            "${aws_dynamodb_table.this.arn}/index/*",
          ]
        }
      ],
      local.kms_key_arn != null ? [
        {
          Effect = "Allow"
          Action = [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:GenerateDataKey",
            "kms:DescribeKey",
          ]
          Resource = [local.kms_key_arn]
        }
      ] : []
    )
  })
}

output "read_write_policy_json" {
  description = "IAM policy JSON for read/write access"
  value = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect = "Allow"
          Action = [
            "dynamodb:GetItem",
            "dynamodb:BatchGetItem",
            "dynamodb:Query",
            "dynamodb:Scan",
            "dynamodb:PutItem",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem",
            "dynamodb:BatchWriteItem",
          ]
          Resource = [
            aws_dynamodb_table.this.arn,
            "${aws_dynamodb_table.this.arn}/index/*",
          ]
        }
      ],
      local.kms_key_arn != null ? [
        {
          Effect = "Allow"
          Action = [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:GenerateDataKey",
            "kms:DescribeKey",
          ]
          Resource = [local.kms_key_arn]
        }
      ] : []
    )
  })
}
