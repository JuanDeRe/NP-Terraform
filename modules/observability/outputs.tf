output "log_group_names" {
  description = "CloudWatch Log Groups indexed by service name."

  value = {
    for service_name, log_group
    in aws_cloudwatch_log_group.service :
    service_name => log_group.name
  }
}

output "log_group_arns" {
  description = "CloudWatch Log Group ARNs indexed by service name."

  value = {
    for service_name, log_group
    in aws_cloudwatch_log_group.service :
    service_name => log_group.arn
  }
}