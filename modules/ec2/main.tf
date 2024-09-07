resource "aws_security_group" "eksctl_host_sg" {
  vpc_id = var.vpc_id

  ingress {
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

  network_interface {
    device_index                = 0
    subnet_id                   = var.public_subnet_id
    associate_public_ip_address = true
    security_groups             = [aws_security_group.eksctl_host_sg.id]
  }

  tags = {
    Name = "${var.cluster_base_name}-bastion-EC2"
  }

user_data = file("${path.module}/modules/ec2/user_data.sh")

}
