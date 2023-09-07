#!/bin/bash

SERVICE_NAMES=("ssh" "redis-server" "cron" "nginx" "passenger-exporter" "foremand-supervisor")
trap 'for i in "${SERVICE_NAMES[@]}"; do echo "Stopping $i"; service $i stop; [[ $i == "redis-server" ]] && killall redis-server; done; exit 1' INT QUIT TERM

bash /erb.templates/render.sh
bash /bootstrap.sh
chown -R webapp:webapp /home/webapp &

service --status-all

ruby /start_services.rb $(echo "${SERVICE_NAMES[@]}")

service --status-all

echo
pstree

echo "All services started. Waiting for interrupt..."
wait
tail --pid=$$ -f /dev/null
