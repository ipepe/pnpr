#!/usr/bin/env bash

sudo locale-gen "en_US.UTF-8"
sudo -u root "echo >> /etc/environment"
sudo -u root "echo LC_ALL=en_US.UTF-8 >> /etc/environment"
sudo -u root "echo LANG=en_US.UTF-8>> /etc/environment"