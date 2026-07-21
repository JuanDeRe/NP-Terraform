variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "service_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "image_uri" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "iam_instance_profile_name" {
  type = string
}

variable "environment_variables" {
  type      = map(string)
  sensitive = true
  default   = {}
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "enable_game_instance_identity" {
  type    = bool
  default = false
}

variable "enable_gateway_instance_identity" {
  type    = bool
  default = false
}

variable "additional_alb_ports" {
  description = "Additional container ports accepted from the ALB."
  type        = set(number)
  default     = []
}

variable "disable_scale_in" {
  description = "Prevents the target tracking policy from automatically reducing capacity."
  type        = bool
  default     = false
}

variable "aws_region" {
  description = "AWS Region where the service is deployed."
  type        = string
}

variable "cloudwatch_log_group_name" {
  description = "CloudWatch Log Group used by the Docker awslogs driver."
  type        = string
}

variable "ami_id" {
  description = "AMI used by service instances."
  type        = string
}
variable "game_capacity_target" {
  description = "Target GameService match capacity utilization."
  type        = number
  default     = 60
}
variable "cpu_disable_scale_in" {
  description = "Disables scale-in for the CPU policy."
  type        = bool
  default     = false
}