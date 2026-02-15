environment        = "production"
aws_profile        = "production"
desired_count      = 3
cpu                = 512
memory             = 1024
enable_autoscaling = true
autoscaling_min    = 2
autoscaling_max    = 10
log_retention_days = 90

# Redis — HA in production
enable_redis             = true
redis_node_type          = "cache.t3.small"
redis_num_cache_nodes    = 2
redis_automatic_failover = true
redis_multi_az           = true

# SQS
enable_sqs = true

# Monitoring
enable_monitoring = true
alert_email       = "platform-oncall@bb.com"
