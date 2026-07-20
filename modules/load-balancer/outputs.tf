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