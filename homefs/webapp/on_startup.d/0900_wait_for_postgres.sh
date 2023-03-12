#!/bin/bash

set -e

echo "Currently running file: $0"

echo "Waiting for postgres to start"
WAIT_LIMIT=60
WAIT_COUNT=0
until psql -h postgres_db -U webapp -c '\l' &> /dev/null
do
    echo "Waiting for postgres to start"
    sleep 1
    WAIT_COUNT=$((WAIT_COUNT+1))
    if [ $WAIT_COUNT -gt $WAIT_LIMIT ]; then
        echo "Postgres did not start in time"
        exit 1
    fi
done
echo "Postgres is listening"