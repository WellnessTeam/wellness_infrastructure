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