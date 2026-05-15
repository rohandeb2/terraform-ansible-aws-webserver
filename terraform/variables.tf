variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"   # Mumbai — closest to you in Roorkee
}

variable "project_name" {
  description = "Project identifier used in all resource names"
  type        = string
  default     = "devops-training"
}


variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_pair_name" {
  description = "Name of your existing AWS key pair"
  type        = string
  # Set this in terraform.tfvars
}

variable "allowed_ssh_cidr" {
  description = "Your IP for SSH access — never use 0.0.0.0/0 in production"
  type        = string
  # Set this in terraform.tfvars — find your IP at https://checkip.amazonaws.com
}


variable "asg_min" {
  type = number
}

variable "asg_desired" {
  type = number
}

variable "asg_max" {
  type = number
}

variable "db_password" {
  type      = string
  sensitive = true  # Terraform will never print this in logs
}