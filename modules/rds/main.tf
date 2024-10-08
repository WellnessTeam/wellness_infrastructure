resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.cluster_base_name}-rds-subnetgroup" # 특수 문자 없는 간단한 이름 사용
  subnet_ids = [var.rds_subnet_id, var.rds_subnet_id_2]

  tags = {
    Name = "${var.cluster_base_name}-rds-subnetgroup"
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
  identifier             = "${var.cluster_base_name}-postgres"
  engine                 = "postgres"
  instance_class         = "db.t3.micro" # 원하는 인스턴스 타입으로 변경
  allocated_storage      = 20            # 스토리지 크기
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id] # vpc_security_group_ids 오타 수정
  skip_final_snapshot    = true

  tags = {
    Name = "${var.cluster_base_name}-postgres"
  }
}