resource "aws_efs_file_system" "efs" {
  tags = {
    Name = "${var.cluster_base_name}-EFS"
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count             = length(var.public_subnet_ids)
  file_system_id    = aws_efs_file_system.efs.id
  subnet_id         = var.public_subnet_ids[count.index]  # public_subnet_ids 사용
  security_groups   = [aws_security_group.efs_sg.id]
}
