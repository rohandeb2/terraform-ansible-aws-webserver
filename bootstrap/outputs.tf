# These outputs tell you exactly what to paste into terraform/backend.tf

output "state_bucket_name" {
  description = "Paste this into terraform/backend.tf as 'bucket'"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "Bucket ARN — useful for IAM policies"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "Paste this into terraform/backend.tf as 'dynamodb_table'"
  value       = aws_dynamodb_table.terraform_state_lock.name
}

output "dynamodb_table_arn" {
  description = "Table ARN — useful for IAM policies"
  value       = aws_dynamodb_table.terraform_state_lock.arn
}

output "backend_config_snippet" {
  description = "Copy-paste this entire block into terraform/backend.tf"
  value       = <<-EOT

    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.terraform_state.id}"
        key            = "devops-training/terraform.tfstate"
        region         = "${var.aws_region}"
        encrypt        = true
        dynamodb_table = "${aws_dynamodb_table.terraform_state_lock.name}"
      }
    }

  EOT
}