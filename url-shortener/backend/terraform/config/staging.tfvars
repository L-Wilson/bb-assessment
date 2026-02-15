environment        = "staging"
aws_profile        = "staging"
desired_count      = 2
cpu                = 256
memory             = 512
enable_autoscaling = false
log_retention_days = 30

# Redis — single-node for staging
enable_redis      = true
redis_node_type   = "cache.t3.micro"

# SQS
enable_sqs = true

# Monitoring
enable_monitoring = true
