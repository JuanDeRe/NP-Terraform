output "endpoint" {
  description = "Redis endpoint address."
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "port" {
  description = "Redis port."
  value       = aws_elasticache_cluster.redis.cache_nodes[0].port
}

output "connection_string" {
  description = "Redis connection string used by the services."

  value = format(
    "%s:%s",
    aws_elasticache_cluster.redis.cache_nodes[0].address,
    aws_elasticache_cluster.redis.cache_nodes[0].port
  )
}

output "security_group_id" {
  description = "Redis security group identifier."
  value       = aws_security_group.redis.id
}

output "cluster_id" {
  description = "ElastiCache cluster identifier."
  value       = aws_elasticache_cluster.redis.cluster_id
}