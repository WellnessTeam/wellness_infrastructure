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