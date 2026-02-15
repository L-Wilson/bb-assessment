terraform {
  backend "s3" {
    bucket         = "terraform-state-backend-133954050615"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}
