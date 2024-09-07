resource "aws_security_group" "efs_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # vpc_cidr가 올바르게 정의된 상태에서 사용
  }

  tags = {
    Name = "${var.cluster_base_name}-EFS-SecurityGroup"
  }
}
