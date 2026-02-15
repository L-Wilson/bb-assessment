module "naming" {
  source = "../../../shared-infrastructure/modules/naming-and-tags"

  project             = "bb-assessment"
  app_name            = "urlshortener"
  environment         = var.environment
  team                = "platform"
  criticality         = var.environment == "production" ? "high" : "medium"
  data_classification = "internal"
  contains_pii        = false
  source_repository   = "https://github.com/bb-assessment"
}

module "ecr" {
  source = "../../../shared-infrastructure/modules/ecr-repository"

  repository_name = "${module.naming.id_long}-api"
  encryption_type = "AES256"

  image_tag_mutability             = "IMMUTABLE"
  scan_on_push                     = true
  lifecycle_policy_max_image_count = 30
  lifecycle_policy_untagged_days   = 7

  tags = module.naming.tags
}

module "dynamodb" {
  source = "../../../shared-infrastructure/modules/dynamodb"

  table_name    = "${module.naming.id_long}-urls"
  hash_key      = "shortCode"
  hash_key_type = "S"

  billing_mode                  = "PAY_PER_REQUEST"
  enable_point_in_time_recovery = true
  enable_encryption             = true
  ttl_attribute                 = "expiresAt"
  stream_enabled                = false

  global_secondary_indexes = [
    {
      name            = "longUrl-index"
      hash_key        = "longUrl"
      hash_key_type   = "S"
      projection_type = "ALL"
    }
  ]

  tags = module.naming.tags
}

module "log_group" {
  source = "../../../shared-infrastructure/modules/cloudwatch-log-group"

  log_group_name    = "/ecs/${module.naming.id_long}-api"
  retention_in_days = var.log_retention_days

  tags = module.naming.tags
}

resource "aws_secretsmanager_secret" "api_key" {
  name        = "${module.naming.id_long}/api-key"
  description = "API key for URL shortener service"

  tags = module.naming.tags
}

resource "aws_secretsmanager_secret_version" "api_key" {
  secret_id = aws_secretsmanager_secret.api_key.id
  secret_string = jsonencode({
    API_KEY = "CHANGE_ME_AFTER_DEPLOY"
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}


# Redis (ElastiCache)
module "redis" {
  count  = var.enable_redis ? 1 : 0
  source = "../../../shared-infrastructure/modules/elasticache-redis"

  cluster_id  = "${module.naming.id_long}-cache"
  description = "Redis cache for ${module.naming.id_long}"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids  = data.terraform_remote_state.network.outputs.private_subnet_ids

  allowed_security_group_ids = [] # populated after ECS module is created

  node_type                  = var.redis_node_type
  num_cache_nodes            = var.redis_num_cache_nodes
  automatic_failover_enabled = var.redis_automatic_failover
  multi_az_enabled           = var.redis_multi_az

  tags = module.naming.tags
}

module "sqs" {
  count  = var.enable_sqs ? 1 : 0
  source = "../../../shared-infrastructure/modules/sqs-queue"

  queue_name                 = "${module.naming.id_long}-events"
  visibility_timeout_seconds = 60
  max_receive_count          = 5

  tags = module.naming.tags
}

locals {
  redis_env_vars = var.enable_redis ? [
    { name = "REDIS_HOST", value = module.redis[0].primary_endpoint_address },
    { name = "REDIS_PORT", value = tostring(module.redis[0].primary_endpoint_port) },
  ] : []

  sqs_env_vars = var.enable_sqs ? [
    { name = "SQS_QUEUE_URL", value = module.sqs[0].queue_url },
  ] : []
}

module "ecs_service" {
  source = "../../../shared-infrastructure/modules/ecs-fargate-service"

  service_name    = "${module.naming.id_long}-api"
  cluster_arn     = data.terraform_remote_state.ecs_cluster.outputs.cluster_arn
  vpc_id          = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids      = data.terraform_remote_state.network.outputs.private_subnet_ids
  container_image = "${module.ecr.repository_url}:latest"
  container_port  = var.container_port
  cpu             = var.cpu
  memory          = var.memory
  desired_count   = var.desired_count

  log_group_arn  = module.log_group.log_group_arn
  log_group_name = module.log_group.log_group_name

  environment_variables = concat(
    [
      { name = "NODE_ENV", value = var.environment == "production" ? "production" : "development" },
      { name = "PORT", value = tostring(var.container_port) },
      { name = "DYNAMODB_TABLE", value = module.dynamodb.table_name },
      { name = "AWS_REGION", value = var.aws_region },
    ],
    local.redis_env_vars,
    local.sqs_env_vars,
  )

  secrets = [
    {
      name      = "API_KEY"
      valueFrom = aws_secretsmanager_secret.api_key.arn
    }
  ]

  health_check_path = "/health"

  # ALB
  create_alb     = true
  alb_subnet_ids = data.terraform_remote_state.network.outputs.public_subnet_ids

  # Service Discovery
  enable_service_discovery = false
  enable_xray_tracing      = var.environment == "production"

  # Auto Scaling
  enable_autoscaling       = var.enable_autoscaling
  autoscaling_min_capacity = var.autoscaling_min
  autoscaling_max_capacity = var.autoscaling_max
  autoscaling_cpu_target   = 70

  # DynamoDB access for the task role
  task_role_policy_json = module.dynamodb.read_write_policy_json

  tags = module.naming.tags
}

# SNS Topic — alarm notifications (created when monitoring is enabled)
module "alarm_topic" {
  count  = var.enable_monitoring ? 1 : 0
  source = "../../../shared-infrastructure/modules/sns-topic"

  topic_name          = "${module.naming.id_long}-alarms"
  display_name        = "URL Shortener Alarms (${var.environment})"
  email_subscriptions = var.alert_email != "" ? [var.alert_email] : []

  allow_cloudwatch_alarms = true

  tags = module.naming.tags
}


# CloudWatch Alarms — optional
locals {
  # Extract cluster name from ARN: arn:aws:ecs:REGION:ACCOUNT:cluster/NAME
  ecs_cluster_name        = try(regex("cluster/(.+)$", data.terraform_remote_state.ecs_cluster.outputs.cluster_arn)[0], "")
  alb_arn_suffix          = try(regex("loadbalancer/(.*)$", module.ecs_service.alb_arn)[0], "")
  target_group_arn_suffix = try(regex("(targetgroup/.*)$", module.ecs_service.target_group_arn)[0], "")
}

module "alarms" {
  count  = var.enable_monitoring ? 1 : 0
  source = "../../../shared-infrastructure/modules/cloudwatch-alarms"

  alarm_name_prefix = module.naming.id_long
  sns_topic_arn     = module.alarm_topic[0].topic_arn

  # ALB alarms
  alb_alarms_enabled      = true
  alb_arn_suffix          = local.alb_arn_suffix
  target_group_arn_suffix = local.target_group_arn_suffix

  # ECS alarms
  ecs_alarms_enabled = true
  ecs_cluster_name   = local.ecs_cluster_name
  ecs_service_name   = module.ecs_service.service_name

  # DynamoDB alarms
  dynamodb_alarms_enabled = true
  dynamodb_table_name     = module.dynamodb.table_name

  # ElastiCache alarms (conditional)
  elasticache_alarms_enabled = var.enable_redis
  elasticache_cluster_id     = var.enable_redis ? module.redis[0].cluster_id : null

  # SQS alarms (conditional)
  sqs_alarms_enabled = var.enable_sqs
  sqs_queue_name     = var.enable_sqs ? module.sqs[0].queue_name : null
  sqs_dlq_name       = var.enable_sqs ? module.sqs[0].dlq_name : null

  tags = module.naming.tags
}

# CloudWatch Dashboard — optional
module "dashboard" {
  count  = var.enable_monitoring ? 1 : 0
  source = "../../../shared-infrastructure/modules/cloudwatch-dashboard"

  dashboard_name = "${module.naming.id_long}-dashboard"
  aws_region     = var.aws_region
  service_name   = "URL Shortener"
  environment    = var.environment

  # ALB widgets
  alb_enabled             = true
  alb_arn_suffix          = local.alb_arn_suffix
  target_group_arn_suffix = local.target_group_arn_suffix

  # ECS widgets
  ecs_enabled      = true
  ecs_cluster_name = local.ecs_cluster_name
  ecs_service_name = module.ecs_service.service_name

  # DynamoDB widgets
  dynamodb_enabled    = true
  dynamodb_table_name = module.dynamodb.table_name

  # ElastiCache widgets (conditional)
  elasticache_enabled    = var.enable_redis
  elasticache_cluster_id = var.enable_redis ? module.redis[0].cluster_id : null

  # SQS widgets (conditional)
  sqs_enabled    = var.enable_sqs
  sqs_queue_name = var.enable_sqs ? module.sqs[0].queue_name : null

  # Log widgets
  log_group_name = module.log_group.log_group_name
}
