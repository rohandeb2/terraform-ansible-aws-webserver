# This file is populated using the output from bootstrap
# Run: cd bootstrap && terraform output backend_config_snippet

terraform {
  backend "s3" {
    bucket         = "devops-training-tfstate-959589242185"  # from bootstrap output
    key            = "devops-training/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"                  # from bootstrap output
  }
}
