#!/bin/bash
echo Installing docker...
sudo apt-get update
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
sudo apt-get update
sudo apt-get install -y docker-engine

#status of docker
echo You can check status of docker service with:
echo sudo systemctl status docker

#add current user to docker group to use without sudo
echo "Adding current user to docker group. You have to relog to make this work"
sudo usermod -aG docker $USER

echo "Installing docker-compose"
sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Changing storage driver to devicemapper"
systemctl stop docker
sudo rm -rf /var/lib/docker
sudo sed -i -e '/^ExecStart=/ s/$/ --storage-driver=overlay2/' /lib/systemd/system/docker.service

echo "Reloading services"
sudo systemctl daemon-reload
sudo service docker restart
sudo systemctl restart docker

echo "Current storage driver is: (be worried if its not storage driver)"
sudo docker info | grep Storage\ Driver
