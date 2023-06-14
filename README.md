# pnpr
Run Your passenger nginx postgres ruby the simple way

## Image naming meaing

`v3.3-u20.04-r2.3.1-n10` means:
 * `v3.3` - pnpr version
 * `u20.04` - ubuntu version
 * `r2.3.1` - ruby version
 * `n10` - node version

## Example docker-compose.yml

```yaml
version: '3.2'
services:
  server:
    image: ipepe/pnpr:v3.3-u20.04-r2.3.1-n10
    restart: always
    network_mode: bridge
    healthcheck:
      disable: true
    environment:
      PGPASSWORD: Password1
      RAILS_ENV: 'staging'
    links:
      - postgres_db
    ports:
      - "3322:22"
      - "3080:80"
    volumes:
      - ./data/webapp:/home/webapp/webapp
      - ./data/ssh:/home/webapp/.ssh
    expose:
      - 80
      - 443
    labels:
      - "traefik.enable=true"
      - "traefik.port=80"
      - "traefik.frontend.rule=Host:example.org"
    logging:
      driver: json-file
      options:
        max-size: 50m

  postgres_db:
    network_mode: bridge
    image: postgres:15
    restart: always
    environment:
      POSTGRES_DB: webapp
      POSTGRES_USER: webapp
      POSTGRES_PASSWORD: Password1
    expose:
      - 5432
    volumes:
      - ./data/db:/var/lib/postgresql/data
      - ./data/dbdumps:/dbdumps
```

## Environment variables

| Variable                                                    | Description                                                         |
|-------------------------------------------------------------|---------------------------------------------------------------------|
| `WITHOUT_MALLOC_ARENA_MAX`                                  | Set to `1` to disable `MALLOC_ARENA_MAX=2`                          |
| `RAILS_ENV`                                                 | Rails environment, defaults to `production`                         |
| `RUBY_VERSION`                                              | Ruby version, changing it will not reinstall rbenv                  |
| `NODE_VERSION`                                              | Node version, changing it will not reinstall nodenv                 |
| `RAILS_ENV`                                                 | Rails environment, defaults to `production`                         |
| `NODE_ENV`                                                  | Node environment, defaults to `production`                          |
| `PASSENGER_FRIENDLY_ERROR_PAGES`                            | Set to `on` to enable friendly error pages. Set to `off` to disable |
| `PASSENGER_MAX_REQUEST_QUEUE_SIZE`                          | Default is `1000`, change it based on your preferences              |
| `PASSENGER_MAX_POOL_SIZE`                                   | Default is `60`, change it based on your preferences                |
| `PASSENGER_FRIENDLY_ERROR_PAGES`                            | Set to `on` to enable friendly error pages. Set to `off` to disable |
| `NO_ACTION_CABLE`                                           | Set to `1` to disable action cable                                  |
| `CABLE_PASSENGER_FORCE_MAX_CONCURRENT_REQUESTS_PER_PROCESS` | Default is `0`, change it based on your preferences                 |
| `PASSENGER_MAX_REQUESTS`                                    | Default is `3000`, change it based on your preferences              |


## Cron/whenever is not working

It's probably because bundler command is not found. To ensure that env path is included in cron add
`env :PATH, ENV['PATH']` to `schedule.rb`