variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
    description = "List of public subnet IDs"
    type = list(string)
}

variable "efs_security_group_id" {
    description = "Security Group ID for EFS"
    type = string
}

variable "cluster_base_name" {
    description = "Base name for the cluster"
    type = string
}