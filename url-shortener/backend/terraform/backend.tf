terraform {
  backend "s3" {
    bucket  = "terraform-state-backend-133954050615"
    region  = "eu-central-1"
    encrypt = true
    # key, profile, use_lockfile set via backend-<env>.tfvars
  }
}
