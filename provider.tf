provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "NightwatchProtocol"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}