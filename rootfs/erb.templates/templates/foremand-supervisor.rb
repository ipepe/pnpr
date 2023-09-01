#!/usr/bin/env ruby

require "erb"

FILE_PATH = "/etc/init.d/foremand-supervisor".freeze

RAILS_ENV = ENV.fetch("RAILS_ENV", "production")

TEMPLATE = <<~ERB.freeze
  #!/bin/bash
  ### BEGIN INIT INFO
  # Provides:          foremand-supervisor
  # Required-Start:    $all
  # Required-Stop:     $local_fs
  # Default-Start:     2 3 4 5
  # Default-Stop:      0 1 6
  # Short-Description: foremand-supervisor daemon
  # Description:       foremand-supervisor daemon for managing Rails applications.
  ### END INIT INFO
  
  # Load the LSB init functions
  . /lib/lsb/init-functions
  
  case "$1" in
    start)
      log_daemon_msg "Starting foremand-supervisor"
      foremand-supervisor start #{RAILS_ENV}
      log_end_msg $?
      ;;
    stop)
      log_daemon_msg "Stopping $APP_NAME"
      killall foremand-supervisor
      ;;
    restart|force-reload)
      $0 stop
      sleep 1
      $0 start
      ;;
    status)
      test -f /var/run/foreman-server.pid && kill -0 `cat /var/run/foreman-server.pid` > /dev/null 2>&1
      ;;
    *)
      log_action_msg "Usage: $0 {start|stop|restart|force-reload|status}"
      exit 2
      ;;
  esac
  
  exit 0
ERB

File.write(FILE_PATH, ERB.new(TEMPLATE).result)
system("chmod +x #{FILE_PATH}")
