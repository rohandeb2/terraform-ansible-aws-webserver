terraform {
  backend "s3" {
    bucket         = "devops-training-tfstate-959589242185"  
    key            = "devops-training/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"                 
  }
}
