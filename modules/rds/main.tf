resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.cluster_base_name}-rds-subnet-group"
  subnet_ids = [var.rds_subnet_id]

  tags = {
    Name = "${var.cluster_base_name}-rds_subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  vpc_id = var.vpc_id

  # Eks 노드가 있는 VPC에서 오는 트래픽 허용
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # 모든 아웃바운드 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_base_name}-rds-sg"
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = "${var.cluster_base_name}-postgres"
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  name                    = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_groups_ids = [aws_security_group.rds.sg.id]
  skip_final_snapshot     = true

  tags = {
    Name = "${var.cluster_base_name}-postgres"
  }
}
