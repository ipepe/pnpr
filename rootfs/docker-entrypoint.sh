#!/bin/bash

SERVICE_NAMES=("ssh" "redis-server" "cron" "nginx" "passenger-exporter" "foremand-supervisor")
trap 'for i in "${SERVICE_NAMES[@]}"; do log "Stopping $i"; logged_system_call "service $i stop"; [[ $i == "redis-server" ]] && logged_system_call "killall redis-server"; done; exit 1' INT QUIT TERM

bash /erb.templates/render.sh
bash /bootstrap.sh
chown -R webapp:webapp /home/webapp &
ruby /start_services.rb

service --status-all
pstree

echo "All services started. Waiting for interrupt..."


tail --pid=$$ -f /dev/null