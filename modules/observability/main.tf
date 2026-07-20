locals {
  services = toset([
    "auth-service",
    "matchmaking-service",
    "realtime-gateway",
    "game-service"
  ])
}

resource "aws_cloudwatch_log_group" "service" {
  for_each = local.services

  name = "/${var.project_name}/${var.environment}/${each.value}"

  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.project_name}-${var.environment}-${each.value}-logs"

    Service = each.value
  }
}