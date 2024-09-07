output "dynamodb_table_name" {
  description = "The name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_state_lock.name
}
