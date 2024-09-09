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


variable "region" {
  description = "AWS Region"
  type        = string
}

variable "kubernetes_version" {
  description = "kubernetes version for EKS"
  type        = string
}

# EFS ID 변수
variable "efs_id" {
  description = "EFS ID"
  type        = string
}

# 추가된 퍼블릭 서브넷 ID들
variable "public_subnet_1" {
  description = "First Public Subnet ID"
  type        = string
}

variable "public_subnet_2" {
  description = "Second Public Subnet ID"
  type        = string
}

variable "public_subnet_3" {
  description = "Third Public Subnet ID"
  type        = string
}

# 추가된 프라이빗 서브넷 ID들
variable "private_subnet_1" {
  description = "First Private Subnet ID"
  type        = string
}

variable "private_subnet_2" {
  description = "Second Private Subnet ID"
  type        = string
}

variable "private_subnet_3" {
  description = "Third Private Subnet ID"
  type        = string
}

# 워커 노드 설정 관련 추가 변수
variable "worker_node_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
}

variable "worker_node_count" {
  description = "Number of worker nodes"
  type        = number
}

