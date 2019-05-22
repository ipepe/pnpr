#!/bin/bash

source /etc/environment

mkdir -p $PGDATA /data/shared
chown -R webapp:webapp /data/shared
chown -R postgres "$PGDATA"
ln -s /data/shared /home/webapp/webapp/shared
rm -rf /var/lib/postgresql/10/main
ln -s $PGDATA /var/lib/postgresql/10/main
chown -R postgres "$PGDATA"
chown -R postgres /var/lib/postgresql/10/main

if [ ! -f $PGDATA/postgresql.conf ]; then #we can assume that we need a database setup
    gosu postgres /usr/lib/postgresql/10/bin/initdb --encoding=UTF-8 --local=en_US.UTF-8 -D $PGDATA
    service postgresql start
    gosu postgres psql -d template1 -c 'CREATE EXTENSION hstore;'
    gosu postgres psql -d template1 -c 'CREATE EXTENSION pg_trgm;'
    gosu postgres psql -c "CREATE USER webapp WITH PASSWORD 'Password1' LOGIN;"
    gosu postgres psql -c "ALTER USER webapp CREATEDB;"
    gosu postgres psql -c "CREATE DATABASE webapp WITH OWNER webapp ENCODING 'UTF-8' TEMPLATE template1;"
    gosu postgres psql -c "CREATE ROLE readonly LOGIN PASSWORD 'Password1';"
    gosu postgres psql -c "GRANT CONNECT ON DATABASE webapp TO readonly;"
    gosu postgres psql -c "GRANT USAGE ON SCHEMA public TO readonly;"
    gosu postgres psql -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;"
    gosu postgres psql -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readonly;"
else
    service postgresql start
fi

if [ ! -f "/home/webapp/webapp/shared/.env.$RAILS_ENV" ]; then
    echo Generating secret key base
    echo SECRET_KEY_BASE=`cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 128 | head -n 1` > "/home/webapp/webapp/shared/.env.$RAILS_ENV"
    chown webapp:webapp "/home/webapp/webapp/shared/.env.$RAILS_ENV"
fi

if [ ! -f /data/authorized_keys ]; then
    echo "Creating authorized_keys file"
    touch /data/authorized_keys
    rm /home/webapp/.ssh/authorized_keys
    ln -s /data/authorized_keys /home/webapp/.ssh/authorized_keys
    chown webapp:webapp /home/webapp/.ssh/*
fi

service ssh start
service nginx start
service redis-server start
cron

# takes very long, and might not be necessary to start
chown -R webapp:webapp "/home/webapp" &

tail -f /var/log/nginx/access.log
