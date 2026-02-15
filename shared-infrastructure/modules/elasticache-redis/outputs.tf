output "cluster_id" {
  description = "ElastiCache replication group ID"
  value       = aws_elasticache_replication_group.this.id
}

output "primary_endpoint_address" {
  description = "Primary endpoint address"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "primary_endpoint_port" {
  description = "Primary endpoint port"
  value       = var.port
}

output "reader_endpoint_address" {
  description = "Reader endpoint address"
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.this.id
}

output "subnet_group_name" {
  description = "Subnet group name"
  value       = aws_elasticache_subnet_group.this.name
}

output "cache_cluster_ids" {
  description = "List of cache cluster IDs for CloudWatch metrics"
  value       = aws_elasticache_replication_group.this.member_clusters
}
