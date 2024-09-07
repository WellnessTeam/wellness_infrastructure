# data.tf
data "aws_ssm_parameter" "latest_ami_id" {
  name = var.ami_id

  depends_on = [module.vpc]
}