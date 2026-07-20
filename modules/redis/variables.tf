variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "node_type" {
  description = "ElastiCache node type."
  type        = string
  default     = "cache.t4g.micro"
}