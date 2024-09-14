# Default 네임 스페이스 변경
kubectl ns default

# 워커 노드의 IP 변수 선언
N1=$(kubectl get node --label-columns=topology.kubernetes.io/zone --selector=topology.kubernetes.io/zone=ap-northeast-2a -o jsonpath={.items[0].status.addresses[0].address})

N2=$(kubectl get node --label-columns=topology.kubernetes.io/zone --selector=topology.kubernetes.io/zone=ap-northeast-2b -o jsonpath={.items[0].status.addresses[0].address})

N3=$(kubectl get node --label-columns=topology.kubernetes.io/zone --selector=topology.kubernetes.io/zone=ap-northeast-2c -o jsonpath={.items[0].status.addresses[0].address})

echo "export N1=$N1" >> /etc/profile

echo "export N2=$N2" >> /etc/profile

echo "export N3=$N3" >> /etc/profile

# 작업용 인스턴스에서 노드로 보안 그룹 설정
NGSGID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=*ng1* --query "SecurityGroups[*].[GroupId]" --output text)

aws ec2 authorize-security-group-ingress --group-id $NGSGID --protocol '-1' --cidr 192.168.1.100/32

# 노드에 SSH 접근
for node in $N1 $N2 $N3; do ssh ec2-user@$node hostname; done

# AWS Load Balancer Controller 설치
helm repo add eks https://aws.github.io/eks-charts

helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

# ExternalDNS 설치
MyDomain="wellness31.click"
MyDnsHostedZoneId=$(aws route53 list-hosted-zones-by-name --dns-name "$MyDomain". --query "HostedZones[0].Id" --output text)

echo $MyDomain, $MyDnsHostedZoneId

curl -s -O https://raw.githubusercontent.com/cloudneta/cnaeblab/master/_data/externaldns.yaml

MyDomain=$MyDomain MyDnsHostedZoneId=$MyDnsHostedZoneId envsubst < externaldns.yaml | kubectl apply -f -

# kube-ops-view 설치
helm repo add geek-cookbook https://geek-cookbook.github.io/charts/

helm install kube-ops-view geek-cookbook/kube-ops-view --version 1.2.2 --set env.TZ="Asia/Seoul" --namespace kube-system

kubectl patch svc -n kube-system kube-ops-view -p '{"spec":{"type":"LoadBalancer"}}'

kubectl annotate service kube-ops-view -n kube-system "external-dns.alpha.kubernetes.io/hostname=kubeopsview.$MyDomain"

echo -e "Kube Ops View URL = http://kubeopsview.$MyDomain:8080/#scale=1.5"