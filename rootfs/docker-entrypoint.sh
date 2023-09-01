#!/bin/bash

# this script has 3 purposes:
# 1. when receiving interrupt, forward this interrupt to all child processes
# 2. prepare container (file permissions, etc) and start all relevant services in proper order
# 3. reap all zombie/defunct processes

WITHOUT_SERVICE_NAMES=$(echo $WITHOUT_SERVICE_NAMES | tr "," "\n")
DEFAULT_SERVICE_NAMES=("ssh" "redis-server" "cron" "nginx" "passenger-exporter" "foremand-supervisor")
SERVICE_NAMES=()

for i in "${DEFAULT_SERVICE_NAMES[@]}"
do
  skip=
  for j in "${WITHOUT_SERVICE_NAMES[@]}"
  do
    [[ $i == $j ]] && { skip=1; break; }
  done
  [[ -n $skip ]] || SERVICE_NAMES+=("$i")
done

log() {
  echo "[PNPR] $1"
}

logged_system_call() {
  log "Executing: $1"
  eval $1
}

# ==== RECEIVE AND FORWARD INTERRUPT SIGNALS TO CHILD PROCESSES ====
trap 'for i in "${SERVICE_NAMES[@]}"; do log "Stopping $i"; logged_system_call "service $i stop"; [[ $i == "redis-server" ]] && logged_system_call "killall redis-server"; done; exit 1' INT QUIT TERM

# ==== PREPARE CONTAINER AND START SERVICES ====
logged_system_call "bash /erb.templates/render.sh"
logged_system_call "bash /bootstrap.sh"
logged_system_call "chown -R webapp:webapp /home/webapp &"

for i in "${SERVICE_NAMES[@]}"
do
  logged_system_call "service $i start"
done

logged_system_call "foremand start"

logged_system_call "service --status-all"
logged_system_call "pstree"

log "Container prepared and services started"
log "All services started. Waiting for interrupt..."

# ==== REAP ALL ZOMBIE AND DEFUNCT SERVICES ====
tail --pid=$$ -f /dev/null