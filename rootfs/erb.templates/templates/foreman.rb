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
  
      DEBUG_LOG_FILE="$LOG_DIR/$APP_NAME-debug.log"
  
      echo "Starting $APP_NAME with the following configuration:" > "$DEBUG_LOG_FILE"
      echo "  APP_DIR: $APP_DIR" >> "$DEBUG_LOG_FILE"
      echo "  APP_USER: $APP_USER" >> "$DEBUG_LOG_FILE"
      echo "  PID_DIR: $PID_DIR" >> "$DEBUG_LOG_FILE"
      echo "  PID_FILE: $PID_FILE" >> "$DEBUG_LOG_FILE"
      echo "  LOG_DIR: $LOG_DIR" >> "$DEBUG_LOG_FILE"
      echo "  LOG_FILE: $LOG_FILE" >> "$DEBUG_LOG_FILE"
      echo "  BUNDLE_BIN: $BUNDLE_BIN" >> "$DEBUG_LOG_FILE"
      echo "  FOREMAN_CMD: $FOREMAN_CMD" >> "$DEBUG_LOG_FILE"
      echo "  RAILS_ENV: $RAILS_ENV" >> "$DEBUG_LOG_FILE"
  
      su -c "export RAILS_ENV='$RAILS_ENV'; cd '$APP_DIR' && $FOREMAN_CMD start --root '$APP_DIR' > '$LOG_FILE' 2>> '$DEBUG_LOG_FILE' & echo \$! > '$PID_FILE'" "$APP_USER"
  
      log_end_msg $?
  }
  
  status() {
    if [ -e "$PID_FILE" ]; then
        pid="$(cat "$PID_FILE")"
        if ps -p "$pid" > /dev/null; then
            log_success_msg "$APP_NAME is running with PID $pid"
            return 0
        else
            log_failure_msg "$APP_NAME is not running"
            return 1
        fi
    else
        log_failure_msg "$APP_NAME is not running"
        return 1
    fi
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
    status)
        status
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
  esac
  
  exit 0
ERB

File.write(FILE_PATH, ERB.new(TEMPLATE).result)
system("chmod +x #{FILE_PATH}")
