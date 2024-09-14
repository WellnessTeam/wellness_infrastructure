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
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Username for the database"
  type        = string
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

# 새로 추가한 rds_subnet_id 변수
variable "rds_subnet_id" {
  description = "The subnet ID where RDS will be deployed (only one)"
  type        = string
}

variable "rds_subnet_id_2" {
  description = "The second subnet ID where RDS will be deployed"
  type        = string