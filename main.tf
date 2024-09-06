module "vpc" {
    source = "./vpc"
    
    vpc_cidr = var.vpc_cidr
    public_subnet_cidrs = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    cluster_base_name = var.cluster_base_name
    availability_zones = var.availability_zones
}