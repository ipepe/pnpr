#!/bin/bash

# Configuration
APP_ROOT="/home/webapp/webapp/current"
FOREMAN_BIN="/home/webapp/.rbenv/shims/foreman"
PROCFILE="$APP_ROOT/Procfile"
PIDFILE="/home/webapp/webapp/shared/foreman.pid"
LOG_DIR="/home/webapp/webapp/shared/logs"
RUN_AS_USER="webapp"

# Check if user exists
if ! id -u $RUN_AS_USER > /dev/null 2>&1; then
  echo "User $RUN_AS_USER not found. Exiting."
  exit 1
fi

# Create log directory if it doesn't exist
if [ ! -d "$LOG_DIR" ]; then
  mkdir -p "$LOG_DIR"
  chown "$RUN_AS_USER":"$RUN_AS_USER" "$LOG_DIR"
fi

# Function to start foreman
start_foreman() {
  if [ -f "$PIDFILE" ]; then
    echo "PID file exists. Foreman may be already running."
    exit 1
  fi

  echo "Starting Foreman..."
  cd "$APP_ROOT"
  su -s /bin/sh -c "exec $FOREMAN_BIN start -f $PROCFILE -d $APP_ROOT > $LOG_DIR/foreman.log 2>&1" "$RUN_AS_USER" &
  FOREMAN_PID=$!
  echo $FOREMAN_PID > "$PIDFILE"
  sleep 2
  echo "Foreman started with PID $FOREMAN_PID."
}

# Function to stop foreman
stop_foreman() {
  if [ ! -f "$PIDFILE" ]; then
    echo "PID file not found. Foreman may not be running."
    exit 1
  fi

  echo "Stopping Foreman..."
  kill -TERM "$(cat "$PIDFILE")"
  rm -f "$PIDFILE"
  sleep 2
  echo "Foreman stopped."
}

# Parse command-line arguments
case "$1" in
  start)
    start_foreman
    ;;
  stop)
    stop_foreman
    ;;
  restart)
    stop_foreman
    start_foreman
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
    ;;
esac