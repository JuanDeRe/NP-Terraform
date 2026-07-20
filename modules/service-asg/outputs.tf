output "autoscaling_group_name" {
  value = aws_autoscaling_group.service.name
}

output "launch_template_id" {
  value = aws_launch_template.service.id
}

output "security_group_id" {
  value = aws_security_group.service.id
}