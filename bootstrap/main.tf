terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Bootstrap uses LOCAL state intentionally
  # This file is small, has no secrets, and IS committed to git
  # It is the one exception to the "never commit state" rule
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "Terraform"
      Layer     = "bootstrap"
    }
  }
}

# ─── S3 BUCKET ─────────────────────────────────────────────────────────────────
# This is the bucket that stores state for your MAIN terraform project

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  # Prevent accidental deletion of your state bucket
  # terraform destroy will FAIL until you manually set this to false
#   lifecycle {
#     prevent_destroy = true
#   }
}

# Block ALL public access — state files contain sensitive infrastructure data
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning — lets you recover from accidental state corruption
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt all state files at rest with AES-256
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true   # reduces encryption request costs
  }
}

# Enforce HTTPS only — reject all HTTP requests to this bucket
resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  # Must wait for public access block to be applied first
  depends_on = [aws_s3_bucket_public_access_block.terraform_state]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyNonHTTPS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# Transition old state versions to cheaper storage after 90 days
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "expire-old-state-versions"
    status = "Enabled"
    filter {}
    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "STANDARD_IA"   # cheaper for infrequently accessed versions
    }

    noncurrent_version_expiration {
      noncurrent_days = 365             # delete versions older than 1 year
    }
  }
}

# ─── DYNAMODB TABLE ────────────────────────────────────────────────────────────
# One row is written per active terraform apply — prevents concurrent runs

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"   # no capacity planning needed — usage is very low
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"   # String — Terraform writes values like "bucket/key.tfstate-md5"
  }

  # Protect lock table from accidental deletion just like the bucket
#   lifecycle {
#     prevent_destroy = true
#   }

  point_in_time_recovery {
    enabled = true   # lets you restore the table to any point in the last 35 days
  }
}