#!/bin/bash

set -e

echo "Currently running file: $0"
echo "Load environment variables from /etc/environment"
source /etc/environment

cd /home/webapp/webapp/current

bundle exec sidekiq -d -L log/sidekiq.log -C config/sidekiq.yml -e $RAILS_ENV
