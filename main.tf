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
  region              = var.region
  kubernetes_version  = var.kubernetes_version


  # 추가된 변수들 전달
  efs_id                    = module.efs.efs_id
  public_subnet_1           = module.vpc.public_subnet_ids[0]
  public_subnet_2           = module.vpc.public_subnet_ids[1]
  public_subnet_3           = module.vpc.public_subnet_ids[2]
  private_subnet_1          = module.vpc.private_subnet_ids[0]
  private_subnet_2          = module.vpc.private_subnet_ids[1]
  private_subnet_3          = module.vpc.private_subnet_ids[2]
  worker_node_instance_type = var.worker_node_instance_type
  worker_node_count         = var.worker_node_count

  iam_user_access_key_id     = var.iam_user_access_key_id
  iam_user_secret_access_key = var.iam_user_secret_access_key
}

# RDS
module "rds" {
  source             = "./modules/rds"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  cluster_base_name  = var.cluster_base_name
  db_username        = var.db_username
  db_password        = var.db_password
  vpc_cidr           = var.vpc_cidr
  rds_subnet_id      = module.vpc.private_subnet_ids[0]
  rds_subnet_id_2    = module.vpc.private_subnet_ids[1]
}

module "s3_backend" {
  source         = "./modules/s3"
  s3_bucket_name = "wellness-infra-terraform"
}

module "dynamodb_backend" {
  source              = "./modules/dynamodb"
  dynamodb_table_name = "terraform-lock-table"
}

