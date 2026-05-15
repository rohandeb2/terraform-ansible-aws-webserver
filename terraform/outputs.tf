output "alb_dns_name" {
  description = "ALB DNS — use this as your app URL"
  value       = aws_lb.web_alb.dns_name
}

output "asg_name" {
  description = "ASG name"
  value       = aws_autoscaling_group.web_asg.name
}

output "current_workspace" {
  description = "Which environment is active"
  value       = terraform.workspace
}

output "ami_used" {
  description = "AMI ID used — useful for auditing"
  value       = data.aws_ami.amazon_linux.id
}

output "security_group_id" {
  description = "Web SG ID"
  value       = aws_security_group.web_sg.id
}