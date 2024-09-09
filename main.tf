#main.tf
# VPC 모듈 호출
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  cluster_base_name    = var.cluster_base_name
  availability_zones   = var.availability_zones
}

# EFS 모듈 호출
module "efs" {
  source                = "./modules/efs"
  vpc_id                = module.vpc.vpc_id
  vpc_cidr              = var.vpc_cidr
  public_subnet_ids     = module.vpc.public_subnet_ids
  cluster_base_name     = var.cluster_base_name
  efs_security_group_id = module.efs.efs_security_group_id
}


# EC2 모듈 호출
module "ec2" {
  source              = "./modules/ec2"
  vpc_id              = module.vpc.vpc_id
  public_subnet_id    = module.vpc.public_subnet_ids[0]
  cluster_base_name   = var.cluster_base_name
  instance_type       = var.instance_type
  key_name            = var.key_name
  sg_ingress_ssh_cidr = var.sg_ingress_ssh_cidr
  ami_id              = data.aws_ssm_parameter.latest_ami_id.value

  # user_data 템플릿에 region 변수를 전달
  user_data = base64encode(templatefile("${path.module}/modules/ec2/user_data.sh", {
    cluster_base_name = var.cluster_base_name,
    region            = var.region  # 기존 region 변수 사용
  }))
}
module "s3_backend" {
  source         = "./modules/s3"
  s3_bucket_name = "wellness-infra-terraform"
}

module "dynamodb_backend" {
  source              = "./modules/dynamodb"
  dynamodb_table_name = "terraform-lock-table"
}

