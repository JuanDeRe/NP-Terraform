output "dns_name" {
  value = aws_lb.main.dns_name
}

output "security_group_id" {
  value = aws_security_group.alb.id
}

output "target_group_arns" {
  value = {
    auth        = aws_lb_target_group.auth.arn
    game        = aws_lb_target_group.game.arn
    matchmaking = aws_lb_target_group.matchmaking.arn
    gateway     = aws_lb_target_group.gateway.arn
  }
}
output "alb_arn_suffix" {
  description = "Application Load Balancer ARN suffix for CloudWatch metrics."
  value       = aws_lb.main.arn_suffix
}

output "target_group_arn_suffixes" {
  description = "Target Group ARN suffixes for CloudWatch metrics."

  value = {
    auth        = aws_lb_target_group.auth.arn_suffix
    game        = aws_lb_target_group.game.arn_suffix
    matchmaking = aws_lb_target_group.matchmaking.arn_suffix
    gateway     = aws_lb_target_group.gateway.arn_suffix
  }
}