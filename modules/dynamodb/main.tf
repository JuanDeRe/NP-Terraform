resource "aws_dynamodb_table" "users" {
  name         = "NP-Users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Username"

  attribute {
    name = "Username"
    type = "S"
  }

  point_in_time_recovery {
    enabled = false
  }

  deletion_protection_enabled = false

  tags = {
    Name = "${var.project_name}-${var.environment}-users"
  }
}