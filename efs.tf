resource "aws_efs_file_system" "efs" {
  tags = {
    Name = "${var.cluster_base_name}-EFS"
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count = length(var.public_subnet_blocks)

  file_system_id      = aws_efs_file_system.efs.id
  subnet_id           = aws_subnet.public_subnet[count.index].id
  aws_security_groups = [aws_security_group.efs_sg.id]
}
