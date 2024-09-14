variable "vpc_id" {
  description = "The ID of the VPC where RDS will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "cluster_base_name" {
  description = "Base name for the resources"
  type        = string
}

variable "db_name" {
  description = "eksDB"
  type        = string
}

variable "db_username" {
  description = "eks"
  type        = string
}

variable "db_password" {
  description = "wellness"
  type        = string
  sensitive   = true
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}
