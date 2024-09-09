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
    efs_id                     = module.efs.efs_id,
    iam_user_access_key_id     = var.iam_user_access_key_id,
    iam_user_secret_access_key = var.iam_user_secret_access_key,
    public_subnet_1            = module.vpc.public_subnet_ids[0],
    public_subnet_2            = module.vpc.public_subnet_ids[1],
    public_subnet_3            = module.vpc.public_subnet_ids[2],
    private_subnet_1           = module.vpc.private_subnet_ids[0],
    private_subnet_2           = module.vpc.private_subnet_ids[1],
    private_subnet_3           = module.vpc.private_subnet_ids[2],
    worker_node_instance_type  = var.worker_node_instance_type,
    worker_node_count          = var.worker_node_count
  }))

}
