# ALB Alarms
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  count = var.alb_alarms_enabled ? 1 : 0

  alarm_name          = "${var.alarm_name_prefix}-alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.alb_5xx_threshold
  alarm_description   = "ALB 5xx errors exceeded ${var.alb_5xx_threshold}"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_4xx" {
  count = var.alb_alarms_enabled ? 1 : 0

  alarm_name          = "${var.alarm_name_prefix}-alb-4xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.alb_4xx_threshold
  alarm_description   = "ALB 4xx errors exceeded ${var.alb_4xx_threshold}"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [var.sns_topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_latency" {
  count = var.alb_alarms_enabled ? 1 : 0

  alarm_name          = "${var.alarm_name_prefix}-alb-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  extended_statistic  = "p99"
  threshold           = var.alb_latency_threshold_ms / 1000
  alarm_description   = "ALB p99 latency exceeded ${var.alb_latency_threshold_ms}ms"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  count = var.alb_alarms_enabled && var.target_group_arn_suffix != null ? 1 : 0

  alarm_name          = "${var.alarm_name_prefix}-alb-unhealthy-hosts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Maximum"
  threshold           = var.alb_unhealthy_host_threshold
  alarm_description   = "Unhealthy hosts >= ${var.alb_unhealthy_host_threshold}"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

# ECS Alarms
resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  count = var.ecs_alarms_enabled ? 1 : 0

  alarm_name          = "${var.alarm_name_prefix}-ecs-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.ecs_cpu_threshold
  alarm_description   = "ECS CPU utilization exceeded ${var.ecs_cpu_threshold}%"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory" {
  count = var.ecs_alarms_enabled ? 1 : 0

  alarm_name          = "${var.alarm_name_prefix}-ecs-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.ecs_memory_threshold
  alarm_description   = "ECS memory utilization exceeded ${var.ecs_memory_threshold}%"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_running_tasks" {
  count = var.ecs_alarms_enabled ? 1 : 0

  alarm_name          = "${var.alarm_name_prefix}-ecs-running-tasks"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = 300
  statistic           = "Minimum"
  threshold           = var.ecs_running_task_threshold
  alarm_description   = "Running tasks below ${var.ecs_running_task_threshold}"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

###############################################################################
# DynamoDB Alarms
###############################################################################
resource "aws_cloudwatch_metric_alarm" "dynamodb_read_throttle" {
  count = var.dynamodb_alarms_enabled ? 1 : 0

  alarm_name          = "${var.alarm_name_prefix}-dynamodb-read-throttle"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ReadThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.dynamodb_read_throttle_threshold
  alarm_description   = "DynamoDB read throttle events exceeded threshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = var.dynamodb_table_name
  }

  alarm_actions = [var.sns_topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_write_throttle" {
  count = var.dynamodb_alarms_enabled ? 1 : 0

  alarm_name          = "${var.alarm_name_prefix}-dynamodb-write-throttle"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "WriteThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.dynamodb_write_throttle_threshold
  alarm_description   = "DynamoDB write throttle events exceeded threshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = var.dynamodb_table_name
  }

  alarm_actions = [var.sns_topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_system_errors" {
  count = var.dynamodb_alarms_enabled ? 1 : 0

  alarm_name          = "${var.alarm_name_prefix}-dynamodb-system-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "SystemErrors"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.dynamodb_system_errors_threshold
  alarm_description   = "DynamoDB system errors exceeded threshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = var.dynamodb_table_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

###############################################################################
# ElastiCache Alarms
###############################################################################
resource "aws_cloudwatch_metric_alarm" "elasticache_cpu" {
  count = var.elasticache_alarms_enabled ? 1 : 0

  alarm_name          = "${var.alarm_name_prefix}-redis-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "EngineCPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = var.elasticache_cpu_threshold
  alarm_description   = "Redis CPU exceeded ${var.elasticache_cpu_threshold}%"

  dimensions = {
    CacheClusterId = var.elasticache_cluster_id
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "elasticache_memory" {
  count = var.elasticache_alarms_enabled ? 1 : 0

  alarm_name          = "${var.alarm_name_prefix}-redis-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = var.elasticache_memory_threshold
  alarm_description   = "Redis memory exceeded ${var.elasticache_memory_threshold}%"

  dimensions = {
    CacheClusterId = var.elasticache_cluster_id
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "elasticache_evictions" {
  count = var.elasticache_alarms_enabled ? 1 : 0

  alarm_name          = "${var.alarm_name_prefix}-redis-evictions"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Evictions"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Sum"
  threshold           = var.elasticache_evictions_threshold
  alarm_description   = "Redis evictions exceeded ${var.elasticache_evictions_threshold}"
  treat_missing_data  = "notBreaching"

  dimensions = {
    CacheClusterId = var.elasticache_cluster_id
  }

  alarm_actions = [var.sns_topic_arn]

  tags = var.tags
}

###############################################################################
# SQS Alarms
###############################################################################
resource "aws_cloudwatch_metric_alarm" "sqs_message_age" {
  count = var.sqs_alarms_enabled ? 1 : 0

  alarm_name          = "${var.alarm_name_prefix}-sqs-message-age"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Maximum"
  threshold           = var.sqs_message_age_threshold
  alarm_description   = "SQS oldest message age exceeded ${var.sqs_message_age_threshold}s"

  dimensions = {
    QueueName = var.sqs_queue_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "sqs_dlq_messages" {
  count = var.sqs_alarms_enabled && var.sqs_dlq_name != null ? 1 : 0

  alarm_name          = "${var.alarm_name_prefix}-sqs-dlq-messages"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Sum"
  threshold           = var.sqs_dlq_messages_threshold
  alarm_description   = "DLQ has messages - possible processing failures"

  dimensions = {
    QueueName = var.sqs_dlq_name
  }

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]

  tags = var.tags
}
