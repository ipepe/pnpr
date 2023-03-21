#!/usr/bin/env ruby

require "erb"

FILE_PATH = "/etc/init.d/sidekiq".freeze

File.write(FILE_PATH, ERB.new(DATA.read).result)
system("chmod +x #{FILE_PATH}")

__END__
#!/bin/bash
### BEGIN INIT INFO
# Provides:          sidekiq
# Required-Start:    $network $local_fs $remote_fs
# Required-Stop:     $network $local_fs $remote_fs
# Should-Start:      $syslog
# Should-Stop:       $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Manage Sidekiq background worker
# Description:       Manages Sidekiq as a background worker daemon.
### END INIT INFO

# Customize this based on your bundler location, app directory, etc.
APP_ROOT="/home/webapp/webapp/current"
PIDFILE="/home/webapp/webapp/shared/sidekiq.pid"
LOGFILE="$APP_ROOT/log/sidekiq.log"
RAILS_ENV="<%= ENV.fetch('RAILS_ENV') %>"
SIDEKIQ_OPTIONS="-e $RAILS_ENV -C $APP_ROOT/config/sidekiq.yml"
BUNDLE_BIN="/home/webapp/.rbenv/shims/bundle"
SIDEKIQ_BIN="$BUNDLE_BIN exec sidekiq"

set -e

start() {
  cd $APP_ROOT
  su webapp -c "$SIDEKIQ_BIN $SIDEKIQ_OPTIONS 2>>$LOGFILE >>$LOGFILE &"
  echo $! > $PIDFILE
}

stop() {
  cd $APP_ROOT
  su webapp -c "kill -s TERM `cat $PIDFILE`"
  rm -f $PIDFILE
}

status() {
  cd $APP_ROOT
  if [ -f $PIDFILE ]; then
    echo "Sidekiq is running with PID `cat $PIDFILE`."
  else
    echo "Sidekiq is not running."
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