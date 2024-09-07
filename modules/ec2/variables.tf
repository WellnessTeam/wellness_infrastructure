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

variable "user_data" {
  description = "User data script"
  type        = string
}
