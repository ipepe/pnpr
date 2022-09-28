#!/bin/bash

set -e

echo "Currently running file: $0"
source /home/webapp/.bashrc

cd /home/webapp/webapp/current

/home/webapp/.rbenv/shims/bundle exec sidekiq -d -L log/sidekiq.log -C config/sidekiq.yml -e $RAILS_ENV
