output "id_long" {
  description = "Long format identifier: {project}-{app_name}-{environment}"
  value       = local.id_long
}

output "id_short" {
  description = "Short format identifier: {app_short}-{env_short}"
  value       = local.id_short
}

output "id_hash" {
  description = "Short identifier with hash suffix for globally unique names"
  value       = "${local.id_short}-${random_string.hash.result}"
}

output "tags" {
  description = "Standardized tags map"
  value       = local.tags
}

output "environment_short" {
  description = "Short environment code (development/stg/prd)"
  value       = local.environment_short
}

output "app_short" {
  description = "Short application name code"
  value       = local.app_short
}

output "project" {
  description = "Project name passthrough"
  value       = var.project
}
