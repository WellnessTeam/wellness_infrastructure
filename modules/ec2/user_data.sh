#!/bin/bash

# 호스트 이름 설정
hostnamectl --static set-hostname "${cluster_base_name}-bastion-EC2"

# 편의성 설정
echo 'alias vi=vim' >> /etc/profile
echo "sudo su -" >> /home/ec2-user/.bashrc

# 타임존 변경 (Asia/Seoul로 설정)
sed -i "s/UTC/Asia\/Seoul/g" /etc/sysconfig/clock
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# 패키지 설치
cd /root
yum -y install tree jq git htop lynx amazon-efs-utils

# kubectl 설치
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/${kubernetes_version}/2023-04-19/bin/linux/amd64/kubectl
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# helm 설치
curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# eksctl 설치
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin

# AWS CLI v2 설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip >/dev/null 2>&1
sudo ./aws/install
complete -C '/usr/local/bin/aws_completer' aws
echo 'export AWS_PAGER=""' >> /etc/profile
export AWS_DEFAULT_REGION=${aws_default_region}
echo "export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" >> /etc/profile

# Docker 설치
amazon-linux-extras install docker -y
systemctl start docker && systemctl enable docker

# EFS 마운트
mkdir -p /mnt/myefs
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_id}.efs.${aws_default_region}.amazonaws.com:/ /mnt/myefs

# SSH 키페어 생성
ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa

# IAM 사용자 자격 증명 설정
export AWS_ACCESS_KEY_ID=${iam_user_access_key_id}
export AWS_SECRET_ACCESS_KEY=${iam_user_secret_access_key}
echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" >> /etc/profile
echo "export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" >> /etc/profile
echo "export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" >> /etc/profile

# 클러스터 설정
eksctl create cluster --name $cluster_base_name --region=$AWS_DEFAULT_REGION \
--vpc-public-subnets "$public_subnet_1,$public_subnet_2,$public_subnet_3" \
--vpc-private-subnets "$private_subnet_1,$private_subnet_2,$private_subnet_3" \
--nodegroup-name ng1 --node-type ${worker_node_instance_type} --nodes ${worker_node_count}

echo 'cloudinit End!'
