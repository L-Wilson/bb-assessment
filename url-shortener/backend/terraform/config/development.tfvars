environment        = "development"
aws_profile        = "development"
desired_count      = 1
cpu                = 256
memory             = 512
enable_autoscaling = false
log_retention_days = 14

# Redis — disabled in development
enable_redis = false

# SQS — disabled in development
enable_sqs = false

# Monitoring — disabled in development
enable_monitoring = false
