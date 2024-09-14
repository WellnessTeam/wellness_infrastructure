resource "aws_security_group" "eksctl_host_sg" {
  vpc_id = var.vpc_id

  # Ingress rule (SSH or all traffic inbound)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.sg_ingress_ssh_cidr]
  }

  # Egress rule (all outbound traffic)
  egress {
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

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_base_name          = var.cluster_base_name,
    aws_default_region         = var.region,
    kubernetes_version         = var.kubernetes_version,
    timestamp                  = timestamp(),
    efs_id                     = var.efs_id,
    public_subnet_1            = var.public_subnet_1,
    public_subnet_2            = var.public_subnet_2,
    public_subnet_3            = var.public_subnet_3,
    private_subnet_1           = var.private_subnet_1,
    private_subnet_2           = var.private_subnet_2,
    private_subnet_3           = var.private_subnet_3,
    worker_node_instance_type  = var.worker_node_instance_type,
    worker_node_count          = var.worker_node_count
    worker_node_volume_size    = var.worker_node_volume_size
    iam_user_access_key_id     = var.iam_user_access_key_id,    # 추가
    iam_user_secret_access_key = var.iam_user_secret_access_key # 추가 

  }))
}
