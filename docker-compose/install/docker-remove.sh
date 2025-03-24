echo '======= [1] uninstall old versions =========='
sudo dnf remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

sudo rm -rf /var/lib/docker
sudo rm -rf /etc/docker
sudo rm -rf /var/run/docker.sock

sudo rm /usr/local/bin/docker-compose

sudo groupdel docker

sudo rm -rf ~/.docker