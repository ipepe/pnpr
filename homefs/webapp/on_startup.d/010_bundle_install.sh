#!/bin/bash

set -e

echo "Currently running file: $0"
echo "Load environment variables from /etc/environment"
source /etc/environment

cd /home/webapp/webapp/current

bundle install --without development test --deployment --jobs 4
