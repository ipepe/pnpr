#!/bin/bash
sudo apt-get update
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
sudo apt-get update
sudo apt-get install -y docker-engine

#status of docker
sudo systemctl status docker

#add current user to docker group to use without sudo
sudo usermod -aG docker $USER

sudo sh -c 'curl -L "https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose'
sudo chmod +x /usr/local/bin/docker-compose

echo You have to edit /lib/systemd/system/docker.service to change storage drive to device mapper
exit 0
# or /lib/systemd/system/docker.service
# [Service]
# ExecStart=/usr/bin/docker daemon --storage-driver=devicemapper -H fd://

sudo service docker restart
sudo systemctl daemon-reload
sudo systemctl restart docker

docker info | grep Storage\ Driver
