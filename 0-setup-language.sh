#!/usr/bin/env bash

sudo locale-gen "en_US.UTF-8"
sudo sh -c "echo >> /etc/environment"
sudo sh -c "echo LC_ALL=en_US.UTF-8 >> /etc/environment"
sudo sh -c "echo LANG=en_US.UTF-8>> /etc/environment"