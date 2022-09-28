#!/bin/bash

set -e

echo "Currently running file: $0"
echo "Load environment variables from /etc/environment"
source /etc/environment

if [ ! -f "/home/webapp/webapp/shared/.env.$RAILS_ENV" ]; then
    cd /home/webapp/webapp/shared
    echo Generating secret key base
    echo SECRET_KEY_BASE=`cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 128 | head -n 1` > "/home/webapp/webapp/shared/.env.$RAILS_ENV"
    chown webapp:webapp "/home/webapp/webapp/shared/.env.$RAILS_ENV"
fi