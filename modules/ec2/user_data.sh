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
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.27.1/2023-04-19/bin/linux/amd64/kubectl
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

# IAM Credentials 설정 (선택 사항)
aws configure set aws_access_key_id "${iam_user_access_key_id}"
aws configure set aws_secret_access_key "${iam_user_secret_access_key}"

# yaml highlighter 설치
wget https://github.com/andreazorzetto/yh/releases/download/v0.4.0/yh-linux-amd64.zip
unzip yh-linux-amd64.zip
mv yh /usr/local/bin/

# krew 설치
curl -LO https://github.com/kubernetes-sigs/krew/releases/download/v0.4.3/krew-linux_amd64.tar.gz
tar zxvf krew-linux_amd64.tar.gz
./krew-linux_amd64 install krew
export PATH="$PATH:/root/.krew/bin"
echo 'export PATH="$PATH:/root/.krew/bin"' >> /etc/profile

# krew plugin 설치
kubectl krew install ctx ns get-all df-pv 

# kube-ps1 설치
echo 'source <(kubectl completion bash)' >> /etc/profile
echo 'alias k=kubectl' >> /etc/profile
echo 'complete -F __start_kubectl k' >> /etc/profile

git clone https://github.com/jonmosco/kube-ps1.git /root/kube-ps1
cat <<"EOT" >> /root/.bash_profile
source /root/kube-ps1/kube-ps1.sh
KUBE_PS1_SYMBOL_ENABLE=false
function get_cluster_short() {
  echo "$1" | cut -d . -f1
}
KUBE_PS1_CLUSTER_FUNCTION=get_cluster_short
KUBE_PS1_SUFFIX=') '
PS1='$(kube_ps1)'$PS1
EOT

# Docker 설치
amazon-linux-extras install docker -y
systemctl start docker && systemctl enable docker

# EFS 마운트
export efs_id=${efs_id}
echo "export efs_id=${efs_id}" >> /etc/profile
mkdir -p /mnt/myefs
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $efs_id.efs.$AWS_DEFAULT_REGION.amazonaws.com:/ /mnt/myefs

# SSH 키페어 생성
ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa

# 클러스터 이름
export CLUSTER_NAME=${cluster_base_name}
echo "export CLUSTER_NAME=$CLUSTER_NAME" >> /etc/profile

# k8s Version
export KUBERNETES_VERSION=${kubernetes_version}
echo "export KUBERNETES_VERSION=$KUBERNETES_VERSION" >> /etc/profile

# VPC & Subnet
export VPCID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$CLUSTER_NAME-vpc" | jq -r .Vpcs[].VpcId)
echo "export VPCID=$VPCID" >> /etc/profile
export PubSubnet1=$(aws ec2 describe-subnets --filters Name=tag:Name,Values="$CLUSTER_NAME-public-1" --query "Subnets[0].[SubnetId]" --output text)
export PubSubnet2=$(aws ec2 describe-subnets --filters Name=tag:Name,Values="$CLUSTER_NAME-public-2" --query "Subnets[0].[SubnetId]" --output text)
export PubSubnet3=$(aws ec2 describe-subnets --filters Name=tag:Name,Values="$CLUSTER_NAME-public-3" --query "Subnets[0].[SubnetId]" --output text)
echo "export PubSubnet1=$PubSubnet1" >> /etc/profile
echo "export PubSubnet2=$PubSubnet2" >> /etc/profile
echo "export PubSubnet3=$PubSubnet3" >> /etc/profile
export PrivateSubnet1=$(aws ec2 describe-subnets --filters Name=tag:Name,Values="$CLUSTER_NAME-private-1" --query "Subnets[0].[SubnetId]" --output text)
export PrivateSubnet2=$(aws ec2 describe-subnets --filters Name=tag:Name,Values="$CLUSTER_NAME-private-2" --query "Subnets[0].[SubnetId]" --output text)
export PrivateSubnet3=$(aws ec2 describe-subnets --filters Name=tag:Name,Values="$CLUSTER_NAME-private-3" --query "Subnets[0].[SubnetId]" --output text)
echo "export PrivateSubnet1=$PrivateSubnet1" >> /etc/profile
echo "export PrivateSubnet2=$PrivateSubnet2" >> /etc/profile
echo "export PrivateSubnet3=$PrivateSubnet3" >> /etc/profile

# 클러스터 설정
export worker_node_instance_type=${worker_node_instance_type}
export worker_node_count=${worker_node_count}
export worker_node_volume_size=${worker_node_volume_size}
echo "export worker_node_instance_type=${worker_node_instance_type}" >> /etc/profile
echo "export worker_node_count=${worker_node_count}" >> /etc/profile
echo "export worker_node_volume_size=${worker_node_volume_size}" >> /etc/profile

echo "Starting EKS cluster creation..." | tee -a /var/log/eks_setup.log

eksctl create cluster --name "$CLUSTER_NAME" --region "$AWS_DEFAULT_REGION" \
--nodegroup-name ng1 --node-type "$worker_node_instance_type" --nodes "$worker_node_count" \
--node-volume-size "$worker_node_volume_size" --vpc-public-subnets "$PubSubnet1","$PubSubnet2","$PubSubnet3" \
--version "$kubernetes_version" --max-pods-per-node 50 --ssh-access --ssh-public-key /root/.ssh/id_rsa.pub \
--with-oidc --external-dns-access --full-ecr-access --asg-access --dry-run > myeks.yaml

# certManager: true로 변경
sed -i 's/certManager: false/certManager: true/g' myeks.yaml
# ebs: true로 변경
sed -i 's/ebs: false/ebs: true/g' myeks.yaml
# cloudWatch: true로 변경
sed -i 's/cloudWatch: false/cloudWatch: true/g' myeks.yaml

# CNI, DNS, EBS, EFS
cat <<EOT >> myeks.yaml
addons:
  - name: vpc-cni
    version: latest
    attachPolicyARNs:
      - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
  - name: kube-proxy
    version: latest
  - name: coredns
    version: latest
  - name: aws-ebs-csi-driver
    wellKnownPolicies:
      ebsCSIController: true
  - name: aws-efs-csi-driver
    wellKnownPolicies:
      efsCSIController: true
EOT

# ALB, NLB 관리, 정책 자동으로 할당, EBS볼륨을 관리
cat <<EOT > irsa.yaml
  serviceAccounts:
    - metadata:
        name: aws-load-balancer-controller
        namespace: kube-system
      wellKnownPolicies:
        awsLoadBalancerController: true
    - metadata:
        name: ebs-csi-controller-sa
        namespace: kube-system
      wellKnownPolicies:
        ebsCSIController: true
    - metadata:
        name: efs-csi-controller-sa
        namespace: kube-system
      wellKnownPolicies:
        efsCSIController: true
EOT

# myeks.yaml 파일에서 withOIDC라는 항복이 포함된 줄을 찾아, 해당 줄 바로 아래에 irsa.yaml 파일 내용 삽입
sed -i -n -e '/withOIDC/r irsa.yaml' -e '1,$p' myeks.yaml

# precmd.yaml이라는 파일을 생성하고, EKS 클러스터가 부팅되기 전에 실행될 명령어들 정의
cat <<EOT > precmd.yaml
  preBootstrapCommands:
    - "yum install links tree jq tcpdump sysstat -y"
EOT

# myeks.yaml 파일에서 instanceType이라는 항목을 찾아 그 아래에 precmd.yaml 파일 내용 삽입
sed -i -n -e '/instanceType/r precmd.yaml' -e '1,$p' myeks.yaml

# eksctl을 사용하여 백그라운드에서 실행
nohup eksctl create cluster -f myeks.yaml --verbose 4 --kubeconfig "/root/.kube/config" 1> /root/create-eks.log 2>&1 &

# EKS 클러스터 생성 시작 메시지
echo "EKS cluster creation initiated" | tee -a /var/log/eks_setup.log

# 스크립트 종료 시 상태 표시
if [ $? -eq 0 ]; then
    echo "user_data.sh executed successfully" | tee -a /var/log/eks_setup.log
else
    echo "user_data.sh encountered errors" | tee -a /var/log/eks_setup.log
fi

echo 'cloudinit End!'
