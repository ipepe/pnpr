#!/usr/bin/env ruby

require "erb"

FILE_PATH = "/etc/init.d/foreman".freeze

RAILS_ENV = ENV.fetch("RAILS_ENV", "production")

TEMPLATE = <<~ERB.freeze
  #!/bin/sh
  ### BEGIN INIT INFO
  # Provides:          foreman
  # Required-Start:    $local_fs $network $named $time $syslog
  # Required-Stop:     $local_fs $network $named $time $syslog
  # Default-Start:     2 3 4 5
  # Default-Stop:      0 1 6
  # Description:       Start Foreman to manage the webapp process
  ### END INIT INFO
  
  APP_NAME="foreman"
  APP_DIR="/home/webapp/webapp/current"
  APP_USER="webapp"
  PID_DIR="/home/webapp/webapp/shared"
  PID_FILE="$PID_DIR/$APP_NAME.pid"
  LOG_DIR="$APP_DIR/log"
  LOG_FILE="$LOG_DIR/$APP_NAME.log"
  BUNDLE_BIN="/home/webapp/.rbenv/shims/bundle"
  FOREMAN_CMD="$BUNDLE_BIN exec foreman"
  RAILS_ENV="<%= RAILS_ENV %>"
  
  . /lib/lsb/init-functions
  
  start() {
      log_daemon_msg "Starting $APP_NAME"
  
      if [ ! -d "$PID_DIR" ]; then
          mkdir -p "$PID_DIR"
          chown "$APP_USER":"$APP_USER" "$PID_DIR"
      fi
  
      if [ ! -d "$LOG_DIR" ]; then
          mkdir -p "$LOG_DIR"
          chown "$APP_USER":"$APP_USER" "$LOG_DIR"
      fi
  
      start-stop-daemon --start --background --quiet --pidfile "$PID_FILE" --make-pidfile --chuid "$APP_USER" --exec /bin/sh -- -c "export RAILS_ENV='$RAILS_ENV'; cd '$APP_DIR' && exec $FOREMAN_CMD start -f '$APP_DIR/Procfile' -l '$LOG_DIR' -p '$PID_DIR'"
  
      log_end_msg $?
  }
  
  stop() {
      log_daemon_msg "Stopping $APP_NAME"
  
      start-stop-daemon --stop --quiet --pidfile "$PID_FILE"
  
      log_end_msg $?
  }
  
  case "$1" in
      start)
          start
          ;;
      stop)
          stop
          ;;
      restart)
          stop
          start
          ;;
      *)
          echo "Usage: $0 {start|stop|restart}"
          exit 1
          ;;
  esac
  
  exit 0
ERB

File.write(FILE_PATH, ERB.new(TEMPLATE).result)
system("chmod +x #{FILE_PATH}")
