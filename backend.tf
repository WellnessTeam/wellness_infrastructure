terraform {
  backend "s3" {
    bucket         = "wellenss-infra-terraform"
    key            = "infrastructure/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
