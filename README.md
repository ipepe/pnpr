# pnpr
Run Your passenger nginx postgres ruby the simple way

## Cron/whenever is not working

It's probably because bundler command is not found. To ensure that env path is included in cron add
`env :PATH, ENV['PATH']` to `schedule.rb`

## Customize image

### Other (second) ruby version
```Dockerfile
FROM ipepe/pnpr:v2-ruby-2.7.5-staging

RUN /home/webapp/.rbenv/bin/rbenv install 2.7.5 && \
    /home/webapp/.rbenv/bin/rbenv global 2.7.5 \

RUN rm /home/webapp/webapp/on_startup.d/090_wait_for_postgres.sh

RUN echo "sleep 100" > /home/webapp/webapp/on_startup.d/015_sleep_100.sh
```

### Other node version

```Dockerfile
FROM ipepe/pnpr:v2-staging-ruby-2.7.5

# Install nodejs
RUN n 12.19.0 && npm install -g npm
# addtionally install yarn
RUN npm install -g yarn
```