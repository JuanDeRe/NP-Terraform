output "vpc_id" {
  description = "VPC identifier."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet identifiers."
  value       = aws_subnet.public[*].id
}

output "redis_subnet_ids" {
  description = "Redis subnet identifiers."
  value       = aws_subnet.redis[*].id
}

output "availability_zones" {
  description = "Availability zones used by the VPC."
  value       = local.availability_zones
}