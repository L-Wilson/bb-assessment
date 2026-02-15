# Remote State — Backend service (for ALB DNS name)
data "terraform_remote_state" "backend" {
  backend = "s3"
  config = {
    bucket  = "terraform-state-backend-133954050615"
    key     = "${var.environment}/url-shortener-backend/terraform.tfstate"
    region  = "eu-central-1"
    profile = var.aws_profile
  }
}

# Current AWS context
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
