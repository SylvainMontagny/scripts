#!/bin/bash
sudo apt-get install git wget nano unzip -y

sudo apt-get install iptables -y
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker
sudo docker run hello-world

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x "/usr/local/bin/docker-compose"
sudo ln -s "/usr/local/bin/docker-compose" "/usr/bin/docker-compose"
docker-compose version


