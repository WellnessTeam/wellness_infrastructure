output "ec2_instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.eksctl_host.id
}

output "ec2_public_ip" {
  description = "EC2 Public IP Address"
  value       = aws_instance.eksctl_host.public_ip
}
