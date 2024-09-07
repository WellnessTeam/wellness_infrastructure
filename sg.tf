resource "aws_security_group" "efs_sg" {
  vpc_id = aws_vpc.eks_vpc.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_block]
  }

  tags = {
    Name = "${var.cluster_base_name}-EFS-SecurityGroup"
  }
}