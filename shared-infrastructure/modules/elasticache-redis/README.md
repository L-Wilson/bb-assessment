# elasticache-redis

Terraform module that provisions an Amazon ElastiCache Redis replication group with an associated security group, subnet group, and parameter group. Designed for use within a VPC with configurable high-availability, encryption, and backup settings.

## Usage

```hcl
module "redis" {
  source = "./modules/elasticache-redis"

  cluster_id  = "myapp-redis"
  description = "Redis cache for myapp"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnet_ids

  allowed_security_group_ids = [module.ecs_service.security_group_id]

  node_type       = "cache.t3.micro"
  num_cache_nodes = 2
  engine_version  = "7.0"

  automatic_failover_enabled = true
  multi_az_enabled           = true

  tags = {
    Environment = "production"
    Project     = "myapp"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| cluster_id | Unique identifier for the ElastiCache replication group | `string` | n/a | yes |
| description | Human-readable description of the replication group | `string` | n/a | yes |
| vpc_id | VPC ID where the cluster will be deployed | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for the subnet group | `list(string)` | n/a | yes |
| allowed_security_group_ids | Security group IDs allowed to access Redis | `list(string)` | n/a | yes |
| node_type | ElastiCache node instance type | `string` | `"cache.t3.micro"` | no |
| num_cache_nodes | Number of cache nodes | `number` | `1` | no |
| engine_version | Redis engine version | `string` | `"7.0"` | no |
| port | Port number for Redis | `number` | `6379` | no |
| parameter_group_family | Parameter group family | `string` | `"redis7"` | no |
| automatic_failover_enabled | Enable automatic failover | `bool` | `false` | no |
| multi_az_enabled | Enable Multi-AZ support | `bool` | `false` | no |
| at_rest_encryption_enabled | Enable encryption at rest | `bool` | `true` | no |
| transit_encryption_enabled | Enable in-transit encryption | `bool` | `true` | no |
| auth_token | Auth token for Redis AUTH (sensitive) | `string` | `null` | no |
| kms_key_arn | ARN of the KMS key for at-rest encryption | `string` | `null` | no |
| snapshot_retention_limit | Days to retain automatic snapshots | `number` | `7` | no |
| snapshot_window | Daily backup window (UTC) | `string` | `"03:00-05:00"` | no |
| maintenance_window | Weekly maintenance window (UTC) | `string` | `"sun:05:00-sun:07:00"` | no |
| apply_immediately | Apply changes immediately | `bool` | `false` | no |
| tags | Map of tags for all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | ElastiCache replication group ID |
| primary_endpoint_address | Primary endpoint address |
| primary_endpoint_port | Primary endpoint port |
| reader_endpoint_address | Reader endpoint address |
| security_group_id | Security group ID |
| subnet_group_name | Subnet group name |
| cache_cluster_ids | List of cache cluster IDs for CloudWatch metrics |
