variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
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

variable "cluster_base_name" {
  description = "Base name"
  type        = string
  default     = "wellness_eks"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}
