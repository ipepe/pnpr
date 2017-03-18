#!/bin/bash

source /etc/environment

mkdir -p $PGDATA /data/app
chown -R webapp:webapp  /data/app
ln -s /data/app /home/webapp/webapp/shared
chown -R postgres "$PGDATA"
rm -rf /var/lib/postgresql/9.6/main
ln -s $PGDATA /var/lib/postgresql/9.6/main
chown -R postgres "$PGDATA"
chown -R postgres /var/lib/postgresql/9.6/main

if [ ! -f $PGDATA/postgresql.conf ]; then #we can assume its first run
    gosu postgres /usr/lib/postgresql/9.6/bin/initdb --encoding=UTF-8 --local=en_US.UTF-8 -D $PGDATA
    sudo service postgresql start
    sudo -u postgres psql -d template1 -c 'CREATE EXTENSION hstore;'
    sudo -u postgres psql -d template1 -c 'CREATE EXTENSION pg_trgm;'
    sudo -u postgres psql -c "CREATE USER webapp WITH PASSWORD 'Password1' LOGIN;"
    sudo -u postgres psql -c "ALTER USER webapp CREATEDB;"
    sudo -u postgres psql -c "CREATE DATABASE webapp WITH OWNER webapp ENCODING 'UTF-8' TEMPLATE template1;"
    rm /first_run.marker
else
    service postgresql start
fi

service ssh start
service nginx start
service redis-server start
cron
tail -f /var/log/nginx/access.log
#tail -f --retry /data/app/log/production.log
