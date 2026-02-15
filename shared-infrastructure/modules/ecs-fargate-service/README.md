# ecs-fargate-service

Terraform module that deploys a complete ECS Fargate service with optional ALB, auto scaling, X-Ray tracing, and ECS Service Connect integration.

## Features

- ECS Fargate task definition and service with deployment circuit breaker
- Separate IAM execution role (image pull, log push, secrets access) and task role (application permissions)
- Optional Application Load Balancer with HTTP/HTTPS listeners and TLS termination
- Optional CPU-based auto scaling via Application Auto Scaling
- Optional AWS X-Ray sidecar container for distributed tracing
- Optional ECS Service Connect for service-to-service discovery
- Container health checks and ALB health checks
- Security groups scoped to ALB-to-task traffic only

## Usage

```hcl
module "api_service" {
  source = "../modules/ecs-fargate-service"

  service_name    = "my-api"
  cluster_arn     = aws_ecs_cluster.main.arn
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  container_image = "123456789.dkr.ecr.us-east-1.amazonaws.com/my-api:latest"
  container_port  = 3000

  log_group_arn  = aws_cloudwatch_log_group.api.arn
  log_group_name = aws_cloudwatch_log_group.api.name

  create_alb     = true
  alb_subnet_ids = module.vpc.public_subnet_ids

  environment_variables = [
    { name = "NODE_ENV", value = "production" },
  ]

  enable_autoscaling       = true
  autoscaling_min_capacity = 2
  autoscaling_max_capacity = 8
  autoscaling_cpu_target   = 70

  tags = {
    Environment = "production"
    Service     = "my-api"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| service_name | Name of the ECS service | `string` | - | yes |
| cluster_arn | ARN of the ECS cluster | `string` | - | yes |
| vpc_id | VPC ID where the service will be deployed | `string` | - | yes |
| subnet_ids | List of subnet IDs for ECS tasks | `list(string)` | - | yes |
| container_image | Docker image for the container | `string` | - | yes |
| log_group_arn | ARN of the CloudWatch log group | `string` | - | yes |
| log_group_name | Name of the CloudWatch log group | `string` | - | yes |
| container_port | Port the container listens on | `number` | `3000` | no |
| cpu | CPU units for the task | `number` | `256` | no |
| memory | Memory in MiB for the task | `number` | `512` | no |
| desired_count | Desired number of running tasks | `number` | `2` | no |
| environment_variables | List of environment variables | `list(object)` | `[]` | no |
| secrets | List of secrets from SSM or Secrets Manager | `list(object)` | `[]` | no |
| health_check_path | HTTP path for health checks | `string` | `"/health"` | no |
| enable_xray_tracing | Enable X-Ray tracing sidecar | `bool` | `true` | no |
| enable_service_discovery | Enable ECS Service Connect | `bool` | `true` | no |
| ecs_namespace_arn | ARN of the Service Connect namespace | `string` | `null` | no |
| create_alb | Whether to create an ALB | `bool` | `true` | no |
| alb_subnet_ids | Public subnet IDs for the ALB | `list(string)` | `[]` | no |
| alb_certificate_arn | ACM certificate ARN for HTTPS | `string` | `null` | no |
| alb_ingress_cidr_blocks | CIDR blocks allowed to access the ALB | `list(string)` | `["0.0.0.0/0"]` | no |
| enable_autoscaling | Enable auto scaling | `bool` | `false` | no |
| autoscaling_min_capacity | Minimum task count for auto scaling | `number` | `1` | no |
| autoscaling_max_capacity | Maximum task count for auto scaling | `number` | `10` | no |
| autoscaling_cpu_target | Target CPU utilization percentage | `number` | `70` | no |
| task_role_policy_arns | IAM policy ARNs for the task role | `list(string)` | `[]` | no |
| task_role_policy_json | Inline IAM policy JSON for the task role | `string` | `null` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| service_arn | ECS service ARN |
| service_name | ECS service name |
| task_definition_arn | Task definition ARN |
| task_role_arn | Task IAM role ARN |
| execution_role_arn | Execution IAM role ARN |
| security_group_id | Task security group ID |
| alb_dns_name | ALB DNS name (null if ALB not created) |
| alb_arn | ALB ARN (null if ALB not created) |
| target_group_arn | Target group ARN (null if ALB not created) |
