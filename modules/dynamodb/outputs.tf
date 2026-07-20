output "table_name" {
  description = "DynamoDB users table name."
  value       = aws_dynamodb_table.users.name
}

output "table_arn" {
  description = "DynamoDB users table ARN."
  value       = aws_dynamodb_table.users.arn
}