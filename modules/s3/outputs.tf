output "s3_bucket_id" {
  description = "The ID of the S3 bucket for storing Terraform state"
  value       = aws_s3_bucket.tfstate.id
}
