#!/usr/bin/env bash

#language
sudo locale-gen "en_US.UTF-8"
sudo sh -c "echo >> /etc/environment"
sudo sh -c "echo LC_ALL=en_US.UTF-8 >> /etc/environment"
sudo sh -c "echo LANG=en_US.UTF-8>> /etc/environment"

#swap
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bkp_before_swap_config
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo sysctl vm.swappiness=10
sudo sh -c "echo 'vm.swappiness=10' >> /etc/sysctl.conf"

# updates
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y
