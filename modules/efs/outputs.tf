output "efs_id" {
  value = aws_efs_file_system.efs.id
}

output "efs_security_group_id" {
  description = "ID of the security group for EFS"
  value       = aws_security_group.efs_sg.id
}
