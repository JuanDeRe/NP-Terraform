variable "project_name" {
  description = "Project identifier."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "aws_region" {
  description = "AWS Region."
  type        = string
}

variable "alb_arn_suffix" {
  description = "Application Load Balancer ARN suffix."
  type        = string
}

variable "target_group_arn_suffixes" {
  description = "Target Group ARN suffixes indexed by service."
  type        = map(string)
}

variable "autoscaling_group_names" {
  description = "Auto Scaling Group names indexed by service."
  type        = map(string)
}

variable "redis_cluster_id" {
  description = "ElastiCache cluster identifier."
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB users table name."
  type        = string
}

variable "alarm_actions" {
  description = "ARNs invoked when an alarm changes to ALARM."
  type        = list(string)
  default     = []
}