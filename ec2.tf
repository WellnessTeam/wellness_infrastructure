resource "aws_security_group" "eksctl_host_sg" {
    vpc_id = aws_vpc.eks_vpc.id

    ingress {
        protocol = "-1"
        cidr_blocks = [var.sg_ingress_ssh_cidr]
    }

    tags = {
        Name = "${var.cluster_base_name}-HOST-SG"
    }
}

resource "aws_instance" "eksctl_host" {
    ami = data.aws_ssm_parameter.latest_ami_id.value
    instance_type = var.instance_type
    key_name = var.key_name

    network_interface {
        device_index = 0
        subnet_id = aws_subnet.public_subnet[0].id
        associate_public_ip_address = true
        aws_security_groups = [aws_security_group.eksctl_host_sg.id]
    }
    
    tags = {
        Name = "${var.cluster_base_name}-bastion-EC2"
    }
}