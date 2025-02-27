echo '======= [1] hosts 설정 =========='
#ex echo "192.168.0.10 k8s-controller" | sudo tee -a /etc/hosts
echo "$IP_ADDRESS $HOST_NAME" | sudo tee -a /etc/hosts

echo '======== [2] 방화벽 해제 ========'
# 어차피 포트포워딩을 이용하여 외부 접근을 허용하고 있기 때문에 방화벽이 크게 의미 없을 듯
sudo systemctl stop firewalld && sudo systemctl disable firewalld

echo '======== [3] Swap 비활성화 ========'
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

# 쿠버네티스를 방화벽 포트 open
# control plane인 경우 6443, 2379-2380, 10250, 10259, 10257
# worker node인 경우 10250, 10256, 30000-32767
# sudo firewall-cmd --permanent --add-port=6443/tcp
# sudo firewall-cmd --permanent --add-port=2379-2380/tcp
# sudo firewall-cmd --permanent --add-port=10250/tcp
# sudo firewall-cmd --permanent --add-port=10259/tcp
# sudo firewall-cmd --permanent --add-port=10257/tcp
# sudo firewall-cmd --reload

# container runtime install
# 1. IPV4 packet forwarding 활성화

echo '======== [4] 컨테이너 런타임 설치 전 사전작업 ========'
echo '======== [4-1] iptable 세팅 ========'
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF


# Apply sysctl params without reboot
sudo sysctl --system

echo '======== [4] 컨테이너 런타임 설치(containerd 설치치) ========'
## rpm repository를 이용한 설치
## set up the repostiroy
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

sudo dnf install -y containerd.io-1.7.25-3.1.el9
sudo systemctl daemon-reload
sudo systemctl enable --now containerd

echo '======== [4-1] 컨테이너 런타임 : cri 활성화 및 cgroup driver 설정 ========'
## containerd config default 세팅
sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

## containerd systemd cgroup driver 활성화
sudo sed -i 's/ SystemdCgroup = false/ SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

echo '======== [5] kubeadm 설치 전 세팅 ========'
echo '======== [5-1] repo 설정 ========'
# This overwrites any existing configuration in /etc/yum.repos.d/kubernetes.repo
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

echo '======== [6] SELinux 모드 변경 ========'
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

echo '======== [7] kubelet, kubeadm, kubectl 패키지 설치 ========'
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet