resource "aws_s3_bucket" "tfstate" {
  bucket = var.s3_bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "Terraform State Storage"
  }
}

resource "aws_s3_bucket_versioning" "tfstate_versioning" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}
