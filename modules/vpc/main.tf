# /modules/vpc/main.tf
# vpc
resource "aws_vpc" "eks_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "${var.cluster_base_name}-vpc"
    }
}

# subnets
resource "aws_subnet" "public_subnets" {
    count = 3
    vpc_id = aws_vpc.eks_vpc.id
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]
    map_public_ip_on_launch = true


    tags = {
        Name = "${var.cluster_base_name}-public-${count.index +1}"
        "kubernetes.io/role/elb" = 1
    }
}

resource "aws_subnet" "private_subnets" {
    count = 3
    vpc_id = aws_vpc.eks_vpc.id
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = var.availability_zones[count.index]

    tags = {
        Name = "${var.cluster_base_name}-private-${count.index+1}"
        "kubernetes.io/role/internal-elb" = 1
    }
}

# internet_gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.eks_vpc.id

    tags = {
        Name = "${var.cluster_base_name}-igw"
    }
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.eks_vpc.id

    tags = {
        Name = "${var.cluster_base_name}-public-route-table"
    }
}

resource "aws_route" "public_route" {
    route_table_id = aws_route_table.public_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_rt_association" {
    count = 3
    subnet_id = aws_subnet.public_subnets[count.index].id
    route_table_id = aws_route_table.public_route_table.id
}
