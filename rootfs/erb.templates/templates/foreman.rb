#!/usr/bin/env ruby

require "erb"

FILE_PATH = "/etc/init.d/foreman".freeze

RAILS_ENV = ENV.fetch("RAILS_ENV", "production")

TEMPLATE = <<~ERB.freeze
  #!/bin/bash
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
  FOREMAN_CMD="/home/webapp/.rbenv/shims/foreman"
  RAILS_ENV="staging"
  
  . /lib/lsb/init-functions
  su $APP_USER

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
  
      COMMAND="gosu $APP_USER $FOREMAN_CMD start --root=$APP_DIR"
      start-stop-daemon --start --background --make-pidfile --pidfile "$PID_FILE" --chdir "$APP_DIR" --chuid "$APP_USER" --startas /bin/bash -- -c "exec $COMMAND > '$LOG_FILE' 2>&1"  
      log_end_msg $?
  }
  
  status() {
    if [ -e "$PID_FILE" ]; then
        pid="$(cat "$PID_FILE")"
        if ps -p "$pid" > /dev/null 2>&1; then
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
  
      if [ -e "$PID_FILE" ]; then
          pid="$(cat "$PID_FILE")"
          su -c "kill -TERM $pid" "$APP_USER"
          rm -f "$PID_FILE"
          log_end_msg $?
      else
          log_warning_msg "$APP_NAME is not running"
          log_end_msg 1
      fi
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
