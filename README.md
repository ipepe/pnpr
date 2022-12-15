# pnpr
Run Your passenger nginx postgres ruby the simple way

## Disable Sidekiq

In docker-compose just specify that sidekiq service is /dev/null
```yml
    volumes:
      - /dev/null:/etc/systemd/system/sidekiq.service
```

## Cron/whenever is not working

It's probably because bundler command is not found. To ensure that env path is included in cron add
`env :PATH, ENV['PATH']` to `schedule.rb`