# backend.tf
resource "aws_s3_bucket" "tfstate" {
  bucket = "wellenss-infra-terraform"

  versioning {
    enabled = true
  }

  tags = {
    Name = "Terraform State Storage"
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