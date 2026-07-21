resource "aws_security_group" "redis" {
  name_prefix = "${var.project_name}-${var.environment}-redis-"

  description = "Allows Redis traffic from inside the project VPC."

  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-redis-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_vpc_security_group_egress_rule" "redis_all_ipv4" {
  security_group_id = aws_security_group.redis.id

  description = "Allow outbound IPv4 traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = {
    Name = "${var.project_name}-${var.environment}-redis-egress"
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  name = "${var.project_name}-${var.environment}-redis-subnets"

  subnet_ids = var.subnet_ids

  description = "Subnets used by Nightwatch Redis."

  tags = {
    Name = "${var.project_name}-${var.environment}-redis-subnets"
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id = "${var.project_name}-${var.environment}-redis"

  engine = "redis"

  node_type = var.node_type

  num_cache_nodes = 1

  parameter_group_name = "default.redis7"

  port = 6379

  subnet_group_name = aws_elasticache_subnet_group.redis.name

  security_group_ids = [
    aws_security_group.redis.id
  ]

  apply_immediately = true

  snapshot_retention_limit = 0

  tags = {
    Name = "${var.project_name}-${var.environment}-redis"
  }
}