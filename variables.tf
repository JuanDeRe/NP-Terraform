variable "aws_region" {
  description = "AWS region used by the project."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project resource prefix."
  type        = string
  default     = "nightwatch"
}

variable "jwt_key" {
  description = "JWT signing key shared by AuthService and RealtimeGateway."
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "EC2 instance type used by service Auto Scaling Groups."
  type        = string
  default     = "t3.micro"
}

variable "game_service_max_matches" {
  description = "Maximum active matches reported by each GameService instance."
  type        = number
  default     = 20
}

variable "redis_node_type" {
  description = "ElastiCache Redis node type."
  type        = string
  default     = "cache.t4g.micro"
}

variable "iam_instance_profile_name" {
  description = "Existing Learner Lab EC2 instance profile."
  type        = string
  default     = "LabInstanceProfile"
}

variable "service_ami_id" {
  description = "Pinned Amazon Linux AMI used by Nightwatch service instances."
  type        = string
}