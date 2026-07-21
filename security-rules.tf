resource "aws_vpc_security_group_ingress_rule" "game_from_matchmaking" {
  security_group_id = (
    module.game_service.security_group_id
  )

  referenced_security_group_id = (
    module.matchmaking_service.security_group_id
  )

  description = "GameService HTTP from MatchmakingService"

  from_port   = 8080
  to_port     = 8080
  ip_protocol = "tcp"

  tags = {
    Name = "${var.project_name}-${var.environment}-game-from-matchmaking"
  }
}
resource "aws_vpc_security_group_ingress_rule" "game_from_gateway" {
  security_group_id = (
    module.game_service.security_group_id
  )

  referenced_security_group_id = (
    module.realtime_gateway.security_group_id
  )

  description = "GameService HTTP from RealtimeGateway"

  from_port   = 8080
  to_port     = 8080
  ip_protocol = "tcp"

  tags = {
    Name = "${var.project_name}-${var.environment}-game-from-gateway"
  }
}
resource "aws_vpc_security_group_ingress_rule" "redis_from_matchmaking" {
  security_group_id = (
    module.redis.security_group_id
  )

  referenced_security_group_id = (
    module.matchmaking_service.security_group_id
  )

  description = "Redis from MatchmakingService"

  from_port   = 6379
  to_port     = 6379
  ip_protocol = "tcp"

  tags = {
    Name = "${var.project_name}-${var.environment}-redis-from-matchmaking"
  }
}
resource "aws_vpc_security_group_ingress_rule" "redis_from_game" {
  security_group_id = (
    module.redis.security_group_id
  )

  referenced_security_group_id = (
    module.game_service.security_group_id
  )

  description = "Redis from GameService"

  from_port   = 6379
  to_port     = 6379
  ip_protocol = "tcp"

  tags = {
    Name = "${var.project_name}-${var.environment}-redis-from-game"
  }
}
resource "aws_vpc_security_group_ingress_rule" "redis_from_gateway" {
  security_group_id = (
    module.redis.security_group_id
  )

  referenced_security_group_id = (
    module.realtime_gateway.security_group_id
  )

  description = "Redis from RealtimeGateway"

  from_port   = 6379
  to_port     = 6379
  ip_protocol = "tcp"

  tags = {
    Name = "${var.project_name}-${var.environment}-redis-from-gateway"
  }
}