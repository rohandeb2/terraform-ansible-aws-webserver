variable "aws_region" {
  description = "AWS region for the backend resources"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Used to name all backend resources"
  type        = string
  default     = "devops-training"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for state locking"
  type        = string
  default     = "terraform-state-lock"
}
