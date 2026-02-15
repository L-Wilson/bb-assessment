locals {
  # Build each widget group as a separate list, gated by enable flags.
  # We use jsonencode/jsondecode to avoid Terraform's strict tuple type matching.

  cloudfront_widgets = jsondecode(var.cloudfront_enabled ? jsonencode([
    {
      type   = "metric"
      x      = 0
      y      = 0
      width  = 12
      height = 6
      properties = {
        title   = "CloudFront - Requests & Error Rate"
        metrics = [
          ["AWS/CloudFront", "Requests", "DistributionId", var.cloudfront_distribution_id, "Region", "Global", { stat = "Sum" }],
          ["AWS/CloudFront", "5xxErrorRate", "DistributionId", var.cloudfront_distribution_id, "Region", "Global", { stat = "Average", yAxis = "right" }],
          ["AWS/CloudFront", "4xxErrorRate", "DistributionId", var.cloudfront_distribution_id, "Region", "Global", { stat = "Average", yAxis = "right" }],
        ]
        region = "us-east-1"
        period = 300
        yAxis  = { right = { max = 100 } }
      }
    },
    {
      type   = "metric"
      x      = 12
      y      = 0
      width  = 12
      height = 6
      properties = {
        title   = "CloudFront - Cache Hit Rate & Bytes"
        metrics = [
          ["AWS/CloudFront", "CacheHitRate", "DistributionId", var.cloudfront_distribution_id, "Region", "Global", { stat = "Average" }],
          ["AWS/CloudFront", "BytesDownloaded", "DistributionId", var.cloudfront_distribution_id, "Region", "Global", { stat = "Sum", yAxis = "right" }],
        ]
        region = "us-east-1"
        period = 300
      }
    }
  ]) : "[]")

  alb_widgets = jsondecode(var.alb_enabled ? jsonencode([
    {
      type   = "metric"
      x      = 0
      y      = 6
      width  = 12
      height = 6
      properties = {
        title   = "ALB - Request Count & Latency"
        metrics = [
          ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix, { stat = "Sum" }],
          ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix, { stat = "p99", yAxis = "right" }],
        ]
        region = var.aws_region
        period = 300
      }
    },
    {
      type   = "metric"
      x      = 12
      y      = 6
      width  = 12
      height = 6
      properties = {
        title   = "ALB - HTTP Errors"
        metrics = [
          ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", var.alb_arn_suffix, { stat = "Sum", color = "#d62728" }],
          ["AWS/ApplicationELB", "HTTPCode_ELB_4XX_Count", "LoadBalancer", var.alb_arn_suffix, { stat = "Sum", color = "#ff7f0e" }],
          ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", var.alb_arn_suffix, { stat = "Sum", color = "#2ca02c" }],
        ]
        region = var.aws_region
        period = 300
      }
    }
  ]) : "[]")

  ecs_widgets = jsondecode(var.ecs_enabled ? jsonencode([
    {
      type   = "metric"
      x      = 0
      y      = 12
      width  = 12
      height = 6
      properties = {
        title   = "ECS - CPU & Memory Utilization"
        metrics = [
          ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name, { stat = "Average" }],
          ["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name, { stat = "Average" }],
        ]
        region = var.aws_region
        period = 300
      }
    },
    {
      type   = "metric"
      x      = 12
      y      = 12
      width  = 12
      height = 6
      properties = {
        title   = "ECS - Running Tasks"
        metrics = [
          ["ECS/ContainerInsights", "RunningTaskCount", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name, { stat = "Average" }],
        ]
        region = var.aws_region
        period = 300
      }
    }
  ]) : "[]")

  dynamodb_widgets = jsondecode(var.dynamodb_enabled ? jsonencode([
    {
      type   = "metric"
      x      = 0
      y      = 18
      width  = 12
      height = 6
      properties = {
        title   = "DynamoDB - Read/Write Capacity"
        metrics = [
          ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", var.dynamodb_table_name, { stat = "Sum" }],
          ["AWS/DynamoDB", "ConsumedWriteCapacityUnits", "TableName", var.dynamodb_table_name, { stat = "Sum" }],
        ]
        region = var.aws_region
        period = 300
      }
    },
    {
      type   = "metric"
      x      = 12
      y      = 18
      width  = 12
      height = 6
      properties = {
        title   = "DynamoDB - Latency & Throttles"
        metrics = [
          ["AWS/DynamoDB", "SuccessfulRequestLatency", "TableName", var.dynamodb_table_name, "Operation", "GetItem", { stat = "Average" }],
          ["AWS/DynamoDB", "SuccessfulRequestLatency", "TableName", var.dynamodb_table_name, "Operation", "PutItem", { stat = "Average" }],
          ["AWS/DynamoDB", "ReadThrottleEvents", "TableName", var.dynamodb_table_name, { stat = "Sum", yAxis = "right" }],
          ["AWS/DynamoDB", "WriteThrottleEvents", "TableName", var.dynamodb_table_name, { stat = "Sum", yAxis = "right" }],
        ]
        region = var.aws_region
        period = 300
      }
    }
  ]) : "[]")

  elasticache_widgets = jsondecode(var.elasticache_enabled ? jsonencode([
    {
      type   = "metric"
      x      = 0
      y      = 24
      width  = 12
      height = 6
      properties = {
        title   = "Redis - CPU & Memory"
        metrics = [
          ["AWS/ElastiCache", "EngineCPUUtilization", "CacheClusterId", var.elasticache_cluster_id, { stat = "Average" }],
          ["AWS/ElastiCache", "DatabaseMemoryUsagePercentage", "CacheClusterId", var.elasticache_cluster_id, { stat = "Average" }],
        ]
        region = var.aws_region
        period = 300
      }
    },
    {
      type   = "metric"
      x      = 12
      y      = 24
      width  = 12
      height = 6
      properties = {
        title   = "Redis - Hit Rate & Connections"
        metrics = [
          ["AWS/ElastiCache", "CacheHitRate", "CacheClusterId", var.elasticache_cluster_id, { stat = "Average" }],
          ["AWS/ElastiCache", "CurrConnections", "CacheClusterId", var.elasticache_cluster_id, { stat = "Average", yAxis = "right" }],
        ]
        region = var.aws_region
        period = 300
      }
    }
  ]) : "[]")

  sqs_widgets = jsondecode(var.sqs_enabled ? jsonencode([
    {
      type   = "metric"
      x      = 0
      y      = 30
      width  = 12
      height = 6
      properties = {
        title   = "SQS - Messages"
        metrics = [
          ["AWS/SQS", "NumberOfMessagesSent", "QueueName", var.sqs_queue_name, { stat = "Sum" }],
          ["AWS/SQS", "NumberOfMessagesReceived", "QueueName", var.sqs_queue_name, { stat = "Sum" }],
          ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", var.sqs_queue_name, { stat = "Average", yAxis = "right" }],
        ]
        region = var.aws_region
        period = 300
      }
    },
    {
      type   = "metric"
      x      = 12
      y      = 30
      width  = 12
      height = 6
      properties = {
        title   = "SQS - Message Age"
        metrics = [
          ["AWS/SQS", "ApproximateAgeOfOldestMessage", "QueueName", var.sqs_queue_name, { stat = "Maximum" }],
        ]
        region = var.aws_region
        period = 300
      }
    }
  ]) : "[]")

  log_widgets = jsondecode(var.log_group_name != null ? jsonencode([
    {
      type   = "log"
      x      = 0
      y      = 36
      width  = 24
      height = 6
      properties = {
        title   = "Application Logs - Errors"
        query   = "SOURCE '${var.log_group_name}' | filter @message like /error|Error|ERROR/ | sort @timestamp desc | limit 20"
        region  = var.aws_region
        stacked = false
        view    = "table"
      }
    }
  ]) : "[]")

  # Title widget
  title_widget = [
    {
      type   = "text"
      x      = 0
      y      = 0
      width  = 24
      height = 1
      properties = {
        markdown = "# ${var.service_name} - ${var.environment} Dashboard"
      }
    }
  ]

  # Combine all widgets
  all_widgets = concat(
    local.title_widget,
    local.cloudfront_widgets,
    local.alb_widgets,
    local.ecs_widgets,
    local.dynamodb_widgets,
    local.elasticache_widgets,
    local.sqs_widgets,
    local.log_widgets,
  )
}

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = var.dashboard_name
  dashboard_body = jsonencode({ widgets = local.all_widgets })
}
