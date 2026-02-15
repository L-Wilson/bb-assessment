# KMS key for encryption (created if not provided)
resource "aws_kms_key" "this" {
  count = var.enable_encryption && var.kms_key_arn == null ? 1 : 0

  description             = "KMS key for DynamoDB table ${var.table_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = var.tags
}

resource "aws_kms_alias" "this" {
  count = var.enable_encryption && var.kms_key_arn == null ? 1 : 0

  name          = "alias/dynamodb-${var.table_name}"
  target_key_id = aws_kms_key.this[0].key_id
}

locals {
  kms_key_arn = var.enable_encryption ? (
    var.kms_key_arn != null ? var.kms_key_arn : aws_kms_key.this[0].arn
  ) : null
}

resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key
  range_key    = var.range_key

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  dynamic "attribute" {
    for_each = var.range_key != null ? [1] : []
    content {
      name = var.range_key
      type = var.range_key_type
    }
  }

  # GSI hash key attributes
  dynamic "attribute" {
    for_each = { for gsi in var.global_secondary_indexes : gsi.name => gsi
      if gsi.hash_key != var.hash_key && (var.range_key == null || gsi.hash_key != var.range_key)
    }
    content {
      name = attribute.value.hash_key
      type = attribute.value.hash_key_type
    }
  }

  # GSI range key attributes
  dynamic "attribute" {
    for_each = { for gsi in var.global_secondary_indexes : "${gsi.name}-range" => gsi
      if gsi.range_key != null && gsi.range_key != var.hash_key && (var.range_key == null || gsi.range_key != var.range_key)
    }
    content {
      name = attribute.value.range_key
      type = attribute.value.range_key_type
    }
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  dynamic "server_side_encryption" {
    for_each = var.enable_encryption ? [1] : []
    content {
      enabled     = true
      kms_key_arn = local.kms_key_arn
    }
  }

  dynamic "ttl" {
    for_each = var.ttl_attribute != null ? [1] : []
    content {
      attribute_name = var.ttl_attribute
      enabled        = true
    }
  }

  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = global_secondary_index.value.range_key
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.non_key_attributes
    }
  }

  tags = var.tags
}
