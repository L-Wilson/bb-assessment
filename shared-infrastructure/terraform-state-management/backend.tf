terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "terraform-state-backend-133954050615"
    region       = "eu-central-1"
    encrypt      = true
    key          = "management/terraform.tfstate"
    profile      = "management"
    use_lockfile = true
  }
}
