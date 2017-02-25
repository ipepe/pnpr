#!/usr/bin/env bash

sudo locale-gen "en_US.UTF-8"
sudo -c "echo >> /etc/environment"
sudo -c "echo LC_ALL=en_US.UTF-8 >> /etc/environment"
sudo -c "echo LANG=en_US.UTF-8>> /etc/environment"