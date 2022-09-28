# pnpr
Run Your passenger nginx postgres ruby the simple way

## Cron/whenever is not working

It's probably because bundler command is not found. To ensure that env path is included in cron add
`env :PATH, ENV['PATH']` to `schedule.rb`

## Customize image

```Dockerfile
FROM ipepe/pnpr:v2-ruby-2.7.5-staging

RUN /home/webapp/.rbenv/bin/rbenv install 2.7.5 && \
    /home/webapp/.rbenv/bin/rbenv global 2.7.5 \

RUN rm /home/webapp/webapp/on_startup.d/090_wait_for_postgres.sh

RUN echo "sleep 100" > /home/webapp/webapp/on_startup.d/015_sleep_100.sh
```

## TODO:
 * fix symbolic links
 * dockerfile testing
 * foreman as process keeper?