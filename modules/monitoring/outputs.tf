output "dashboard_name" {
  description = "CloudWatch dashboard name."
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "alarm_names" {
  description = "CloudWatch alarm names."

  value = concat(
    [
      aws_cloudwatch_metric_alarm.alb_5xx.alarm_name,
      aws_cloudwatch_metric_alarm.redis_evictions.alarm_name,
      aws_cloudwatch_metric_alarm.redis_low_memory.alarm_name,
      aws_cloudwatch_metric_alarm.game_capacity_high.alarm_name,
      aws_cloudwatch_metric_alarm.matchmaking_creation_failures.alarm_name,
      aws_cloudwatch_metric_alarm.auth_dynamodb_failures.alarm_name,
      aws_cloudwatch_metric_alarm.gateway_routing_failures.alarm_name,
      aws_cloudwatch_metric_alarm.gateway_game_service_failures.alarm_name
    ],
    values(
      aws_cloudwatch_metric_alarm.unhealthy_targets
    )[*].alarm_name,
    values(
      aws_cloudwatch_metric_alarm.target_5xx
    )[*].alarm_name,
    values(
      aws_cloudwatch_metric_alarm.target_latency
    )[*].alarm_name,
    values(
      aws_cloudwatch_metric_alarm.asg_no_instances
    )[*].alarm_name
  )
}