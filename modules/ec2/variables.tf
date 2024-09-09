variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public Subnet ID"
  type        = string
}

variable "cluster_base_name" {
  description = "Base name for the cluster"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "sg_ingress_ssh_cidr" {
  description = "CIDR for SSH access"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

# 새로 추가된 region 변수
variable "region" {
  description = "AWS Region"
  type        = string
}

variable "kubernetes_version" {
  description = "kubernetes version for EKS"
  type        = string
}