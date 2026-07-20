locals {
  repositories = toset([
    "auth-service",
    "game-service",
    "matchmaking-service",
    "realtime-gateway"
  ])
}

resource "aws_ecr_repository" "service" {
  for_each = local.repositories

  name = "${var.project_name}-${each.value}"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  force_delete = true
}