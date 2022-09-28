#!/bin/bash

docker build . -t ipepe/pnpr:v2-production \
          --build-arg RAILS_ENV=production \
                      NODE_ENV=production \
                      FRIENDLY_ERROR_PAGES=off \
                      WITH_SUDO=false
docker push ipepe/pnpr:v2-production
docker build . -t ipepe/pnpr:v2-staging
docker push ipepe/pnpr:v2-staging
