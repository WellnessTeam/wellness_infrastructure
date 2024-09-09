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

echo 'cloudinit End!'
