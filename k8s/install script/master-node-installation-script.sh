# 클러스터 초기화(--apiserver-advertise-address 이 부분은 control plane ip를 작성할 것)
echo '======= [1] init cluster =========='
sudo kubeadm init --pod-network-cidr=20.96.0.0/16 --apiserver-advertise-address $IP_ADDRESS

# non root user가 kubectl을 사용할 수 있도록 설정
echo '======= [2] set using kubectl locally =========='
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 클러스터 초기화 후 나오는 아래의 정보는 추후 워커 노드 추가 시 필요하니 저장해두기

# Then you can join any number of worker nodes by running the following on each as root:

# kubeadm join {your host ip} --token {token} \
#         --discovery-token-ca-cert-hash {hash}

# CNI 설치
echo '======= [3] install CNI(calico) =========='
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.2/manifests/tigera-operator.yaml

wget https://raw.githubusercontent.com/projectcalico/calico/v3.29.2/manifests/custom-resources.yaml

sed -i 's/192.168.0.0/20.96.0.0/' custom-resources.yaml

kubectl create -f custom-resources.yaml