# backend.tf

resource "aws_s3_bucket" "tfstate" {
  bucket = "wellenss-infra-terraform"

  tags = {
    Name = "Terraform State Storage"
  }
}

resource "aws_s3_bucket_versioning" "tfstate_versioning" {
  bucket =aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "terraform-lock-table"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Tereraform Lock Table"
  }
}