resource "aws_security_group" "eksctl_host_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.sg_ingress_ssh_cidr]
  }

  tags = {
    Name = "${var.cluster_base_name}-HOST-SG"
  }
}

resource "aws_instance" "eksctl_host" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.eksctl_host_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.cluster_base_name}-bastion-EC2"
  }

  # user_data 설정 (templatefile로 동적 변수를 사용)
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_base_name  = var.cluster_base_name,
    aws_default_region = var.region
  }))
}
