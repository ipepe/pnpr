# pnpr
Run Your passenger nginx postgres ruby the simple way

## Cron/whenever is not working

It's probably because bundler command is not found. To ensure that env path is included in cron add
`env :PATH, ENV['PATH']` to `schedule.rb`