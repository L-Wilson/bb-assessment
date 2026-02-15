locals {
  environment_short_map = {
    development = "development"
    staging    = "stg"
    production = "prd"
  }

  app_short_map = {
    urlshortener = "urls"
  }

  environment_short = lookup(local.environment_short_map, var.environment, substr(var.environment, 0, 3))
  app_short         = lookup(local.app_short_map, var.app_name, substr(var.app_name, 0, 4))

  # Naming formats
  id_long  = "${var.project}-${var.app_name}-${var.environment}"
  id_short = "${local.app_short}-${local.environment_short}"

  # Stable timestamp - only changes when resource is recreated
  created_at = timestamp()

  # Standard tags
  tags = merge(
    {
      Project            = var.project
      AppName            = var.app_name
      Environment        = var.environment
      Team               = var.team
      Criticality        = var.criticality
      DataClassification = var.data_classification
      PII                = var.contains_pii ? "true" : "false"
      SourceRepository   = var.source_repository
      ManagedBy          = "terraform"
    },
    var.additional_tags
  )
}

resource "random_string" "hash" {
  length  = 6
  special = false
  upper   = false
}
