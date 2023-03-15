# docker-systemctl-replacement
Source: <https://github.com/gdraheim/docker-systemctl-replacement>

Initially `docker-systemctl-replacement` was supposed to solve a problem of managing `services` in docker container.

## Issues after first deployment
 * `service nginx restart` doesn't work
 * `systemctl restart nginx` doesn't work
 * `/usr/bin/python3 /usr/local/bin/systemctl` takes almost 250MB of RAM