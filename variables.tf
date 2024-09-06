variable "cluster_base_name" {
  type    = string
  default = "wellness_eks"
}

variable "key_name" {
  description = "We are ssh key"
  type        = string
}

variable "iam_user_access_key_id" {
  description = "IAM User - AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "iam_user_secret_access_key" {
  description = "IAM User - AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "sg_ingress_ssh_cidr" {
  description = "The IP address range that can be used to communicate to the EC2 instances"
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  description = "Instance type for EC2"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI ID"
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.26"
}

variable "worker_node_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "worker_node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "availability_zones" {
  description = "List of Availability Zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["192.168.11.0/24", "192.168.12.0/24", "192.168.13.0/24"]
}
