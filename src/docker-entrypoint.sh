#!/bin/bash

echo "Load environment variables from /etc/environment"
source /etc/environment

echo  "Starting services"
service redis-server start
service ssh start
service cron start
service nginx start

echo "Making sure that the user has the correct permissions"
chown -R webapp:webapp "/home/webapp" &

if [ -f "$ON_START_BASH_SCRIPT_PATH" ]; then
  echo "ON_START_BASH_SCRIPT_PATH detected as $ON_START_BASH_SCRIPT_PATH"
  chown -R webapp:webapp "$ON_START_BASH_SCRIPT_PATH"
  gosu webapp bash $ON_START_BASH_SCRIPT_PATH
  echo "ON_START_BASH_SCRIPT_PATH exit code was $?"
else
  echo "ON_START_BASH_SCRIPT_PATH=$ON_START_BASH_SCRIPT_PATH file was not found"
fi

echo "Application started at `date`"
tail -f /var/log/nginx/error.log
