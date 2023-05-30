# pnpr
Run Your passenger nginx postgres ruby the simple way


## Configurable envs (with defaults)

```
ENV RAILS_ENV=production
ENV PASSENGER_MAX_REQUEST_QUEUE_SIZE=1000
ENV PASSENGER_MAX_POOL_SIZE=60
ENV NO_ACTION_CABLE=false
ENV CABLE_PASSENGER_FORCE_MAX_CONCURRENT_REQUESTS_PER_PROCESS=0
ENV PASSENGER_MAX_REQUESTS=3000
ENV FOREMAND_AUTO_RESTART=true
```

## Cron/whenever is not working

It's probably because bundler command is not found. To ensure that env path is included in cron add
`env :PATH, ENV['PATH']` to `schedule.rb`