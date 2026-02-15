###############################################################################
# Remote State - Shared Infrastructure
###############################################################################

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket  = "terraform-state-backend-133954050615"
    key     = "shared/network/terraform.tfstate"
    region  = "eu-central-1"
    profile = var.aws_profile
  }
}

data "terraform_remote_state" "ecs_cluster" {
  backend = "s3"
  config = {
    bucket  = "terraform-state-backend-133954050615"
    key     = "shared/ecs-cluster/terraform.tfstate"
    region  = "eu-central-1"
    profile = var.aws_profile
  }
}

###############################################################################
# Current AWS context
###############################################################################

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
