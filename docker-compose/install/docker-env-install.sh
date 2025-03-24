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
sudo dnf -y install dnf-plugins
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

echo '======= [3] Install the Docker packages =========='
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo '======= [4] Start Docker Engine =========='
sudo systemctl enable --now docker

echo '======= [5] Manage Docker as a non-root user =========='
sudo usermod -aG docker $USER
newgrp docker

echo '======= [6] Configure Docker to start on boot with systemd =========='
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

sudo docker swarm init