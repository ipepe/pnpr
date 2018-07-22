#!/bin/bash

source /etc/environment

mkdir -p $PGDATA /data/app
chown -R webapp:webapp  /data/app
ln -s /data/app /home/webapp/webapp/shared
chown -R postgres "$PGDATA"
rm -rf /var/lib/postgresql/10/main
ln -s $PGDATA /var/lib/postgresql/10/main
chown -R postgres "$PGDATA"
chown -R postgres /var/lib/postgresql/10/main

if [ ! -f $PGDATA/postgresql.conf ]; then #we can assume its first run
    gosu postgres /usr/lib/postgresql/10/bin/initdb --encoding=UTF-8 --local=en_US.UTF-8 -D $PGDATA
    sudo service postgresql start
    sudo -u postgres psql -d template1 -c 'CREATE EXTENSION hstore;'
    sudo -u postgres psql -d template1 -c 'CREATE EXTENSION pg_trgm;'
    sudo -u postgres psql -c "CREATE USER webapp WITH PASSWORD 'Password1' LOGIN;"
    sudo -u postgres psql -c "ALTER USER webapp CREATEDB;"
    sudo -u postgres psql -c "CREATE DATABASE webapp WITH OWNER webapp ENCODING 'UTF-8' TEMPLATE template1;"
    sudo -u postgres psql -c "CREATE ROLE readonly LOGIN PASSWORD 'Password1';"
    sudo -u postgres psql -c "GRANT CONNECT ON DATABASE webapp TO readonly;"
    sudo -u postgres psql -c "GRANT USAGE ON SCHEMA public TO readonly;"
    sudo -u postgres psql -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;"
    sudo -u postgres psql -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readonly;"
    rm /first_run.marker
else
    service postgresql start
fi

if [ ! -f /home/webapp/webapp/shared/.env.production ]; then
    echo Generating secret key base
    mkdir -p /home/webapp/webapp/shared/
    echo SECRET_KEY_BASE=`cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 128 | head -n 1` > /home/webapp/webapp/shared/.env.production
fi

if [ ! -f /data/certs/webapp.crt ]; then
    echo Generating OpenSSL certificate for localhost
    mkdir -p /data/certs/
    openssl req -x509 -newkey rsa:4096 -keyout /data/certs/webapp.key -out /data/certs/webapp.crt -days 2048 -subj '/CN=localhost' -nodes
fi

service ssh start
service nginx start
service redis-server start
cron
tail -f /var/log/nginx/access.log
#tail -f --retry /data/app/log/production.log
