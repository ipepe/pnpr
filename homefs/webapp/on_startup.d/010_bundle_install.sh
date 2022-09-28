#!/bin/bash

set -e

echo "Currently running file: $0"
source /home/webapp/.bashrc

cd /home/webapp/webapp/current

bundle install --without development test --deployment --jobs 4
