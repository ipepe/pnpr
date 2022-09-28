#!/bin/bash

docker build . -t ipepe/pnpr:v2-production \
          --build-arg RAILS_ENV=production \
          --build-arg NODE_ENV=production \
          --build-arg FRIENDLY_ERROR_PAGES=off \
          --build-arg WITH_SUDO=false
docker push ipepe/pnpr:v2-production
docker build . -t ipepe/pnpr:v2-staging
docker push ipepe/pnpr:v2-staging
