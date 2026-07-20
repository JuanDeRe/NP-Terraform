output "ecr_repository_urls" {
  description = "URLs of the ECR repositories."
  value       = module.ecr.repository_urls
}

output "vpc_id" {
  description = "Project VPC identifier."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnets used by the ALB and EC2 instances."
  value       = module.network.public_subnet_ids
}

output "redis_subnet_ids" {
  description = "Subnets used by ElastiCache."
  value       = module.network.redis_subnet_ids
}

output "dynamodb_users_table" {
  description = "Authentication users table."
  value       = module.dynamodb.table_name
}

output "redis_endpoint" {
  description = "Redis endpoint."
  value       = module.redis.endpoint
}

output "redis_connection_string" {
  description = "Redis connection string used by the services."
  value       = module.redis.connection_string
}

output "backend_base_url" {
  description = "Public HTTP URL of the backend."
  value       = "http://${module.load_balancer.dns_name}"
}

output "websocket_url" {
  description = "Public WebSocket URL."
  value       = "ws://${module.load_balancer.dns_name}/game-ws"
}

output "alb_dns_name" {
  value = module.load_balancer.dns_name
}
output "web_client_bucket" {
  description = "S3 bucket containing the Unity WebGL build."
  value       = module.web_client.bucket_name
}

output "web_client_url" {
  description = "Public Unity WebGL website URL."
  value       = module.web_client.website_url
}

output "autoscaling_groups" {
  value = {
    auth        = module.auth_service.autoscaling_group_name
    game        = module.game_service.autoscaling_group_name
    matchmaking = module.matchmaking_service.autoscaling_group_name
    gateway     = module.realtime_gateway.autoscaling_group_name
  }

}