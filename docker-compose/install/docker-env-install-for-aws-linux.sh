echo '======= [1] uninstall old versions =========='
sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

echo '======= [2] Set up the repository =========='
sudo yum update -y

echo '======= [3] Install the Docker packages =========='
sudo yum install -y docker

echo '======= [4] Start Docker Engine =========='
sudo service docker start

echo '======= [5] Manage Docker as a non-root user =========='
sudo usermod -a -G docker ec2-user

echo '======= [6] Configure Docker to start on boot with systemd =========='
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

sudo docker swarm init