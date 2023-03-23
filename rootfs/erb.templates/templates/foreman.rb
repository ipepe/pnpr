#!/usr/bin/env ruby

require "erb"

FILE_PATH = "/etc/init.d/foreman".freeze

RAILS_ENV = ENV.fetch("RAILS_ENV", "production")

TEMPLATE = <<~ERB.freeze
  #!/bin/bash
  ### BEGIN INIT INFO
  # Provides:          foreman
  # Required-Start:    $network $local_fs $remote_fs
  # Required-Stop:     $network $local_fs $remote_fs
  # Should-Start:      $syslog
  # Should-Stop:       $syslog
  # Default-Start:     2 3 4 5
  # Default-Stop:      0 1 6
  # Short-Description: Manage Foreman process manager
  # Description:       Manages Foreman as a process manager daemon.
  ### END INIT INFO
  
  # Customize this based on your bundler location, app directory, etc.
  APP_ROOT="/home/webapp/webapp/current"
  PIDFILE="/home/webapp/webapp/shared/foreman.pid"
  LOGFILE="$APP_ROOT/log/foreman.log"
  RAILS_ENV="<%= RAILS_ENV %>"
  FOREMAN_OPTIONS="-e $RAILS_ENV start -f $APP_ROOT/Procfile"
  BUNDLE_BIN="/home/webapp/.rbenv/shims/bundle"
  FOREMAN_BIN="$BUNDLE_BIN exec foreman"
  
  set -e
  
  start() {
    cd $APP_ROOT
    touch $PIDFILE # create empty PID file
    chown webapp:webapp $PIDFILE # change ownership of PID file
    start-stop-daemon --start --chuid webapp:webapp --chdir $APP_ROOT --pidfile $PIDFILE --make-pidfile --background --exec $FOREMAN_BIN -- $FOREMAN_OPTIONS >>$LOGFILE 2>&1
    echo "Starting Foreman..."
    sleep 1
    if [ -f $PIDFILE ]; then
      echo "Foreman started with PID `cat $PIDFILE`."
    else
      echo "Failed to start Foreman."
    fi
  }
  
  stop() {
    cd $APP_ROOT
    start-stop-daemon --stop --user webapp --pidfile $PIDFILE --remove-pidfile
    echo "Stopping Foreman..."
    sleep 1
    if [ ! -f $PIDFILE ]; then
      echo "Foreman stopped."
    else
      echo "Failed to stop Foreman."
    fi
  }
  
  status() {
    cd $APP_ROOT
    if [ -f $PIDFILE ]; then
      echo "Foreman is running with PID `cat $PIDFILE`."
    else
      echo "Foreman is not running."
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
