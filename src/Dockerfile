FROM ubuntu:16.04
MAINTAINER docker@ipepe.pl

# instalacja podstawowych pakietow i ustawienie kodowania na UTF-8
RUN apt-get update && apt-get install -y locales && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
RUN echo 'LANG="en_US.UTF-8"' > /etc/default/locale
RUN echo 'LANGUAGE="en_US:en"' >> /etc/default/locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# instalacja i konfiguracja Ruby
RUN apt-get update && apt-get install -y \
  git make gcc g++ nodejs npm openssl libssl-dev curl libpq-dev \
  cron libreadline-dev libmagickwand-dev imagemagick wget nano htop sudo apt-utils libjpeg-dev libpng-dev

RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN groupadd -g 1000 webapp
RUN useradd -m -s /bin/bash -g webapp -u 1000 webapp
RUN echo "webapp:Password1" | chpasswd
RUN su - webapp -c "git clone https://github.com/sstephenson/rbenv.git /home/webapp/.rbenv"
RUN echo "export PATH=/home/webapp/.rbenv/bin:/home/webapp/.rbenv/shims:${PATH}" | cat - /home/webapp/.bashrc > /tmp/out && mv /tmp/out /home/webapp/.bashrc
RUN echo "export RBENV_ROOT=/home/webapp/.rbenv" | cat - /home/webapp/.bashrc > /tmp/out && mv /tmp/out /home/webapp/.bashrc
RUN su - webapp -c "git clone https://github.com/sstephenson/ruby-build.git /home/webapp/.rbenv/plugins/ruby-build"
RUN su - webapp -c "rbenv install 2.3.1"
RUN su - webapp -c "rbenv global 2.3.1"
RUN su - webapp -c "echo gem: --no-rdoc --no-ri > ~/.gemrc"
RUN su - webapp -c "gem install bundler"
RUN su - webapp -c "rbenv rehash"

# SSH dla Capistrano
RUN apt-get update && apt-get install -y openssh-server
RUN su - webapp -c "mkdir -p /home/webapp/.ssh"

# instalacja postgres
ENV PGDATA /data/db

RUN curl -o /usr/local/bin/gosu -SL 'https://github.com/tianon/gosu/releases/download/1.1/gosu' \
	&& chmod +x /usr/local/bin/gosu

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update && apt-get install -y postgresql-10 postgresql-contrib-10 postgresql-client-10
RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql
ENV PATH /usr/lib/postgresql/10/bin:$PATH
RUN rm -rf /var/lib/postgresql/10/main

# Instalacja Nginx + Passenger
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7 && \
 apt-get update && apt-get install -y apt-transport-https ca-certificates && \
 echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main" > /etc/apt/sources.list.d/passenger.list && \
 chown root: /etc/apt/sources.list.d/passenger.list && \
 chmod 600 /etc/apt/sources.list.d/passenger.list && \
 apt-get update && \
 apt-get install -y nginx-extras passenger

# konfiguracja Nginx pod aplikacje
COPY ./nginx.conf /etc/nginx/
RUN rm -f /etc/nginx/sites-enabled/default
COPY ./webapp.conf /etc/nginx/sites-available/webapp
RUN ln -s /etc/nginx/sites-available/webapp /etc/nginx/sites-enabled/webapp
RUN usermod -a -G sudo webapp

RUN apt-get update && apt-get -y install redis-server
COPY ./sidekiq.conf /etc/init/sidekiq.conf

COPY ./authorized_keys /home/webapp/.ssh/
RUN chown webapp:webapp /home/webapp/.ssh/authorized_keys && chmod 600 /home/webapp/.ssh/authorized_keys

ENV DB_USER=webapp DB_PASSWORD=Password1 DB_NAME=webapp RAILS_ENV=production
RUN echo RAILS_ENV=production >> /home/webapp/.bashrc
COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh && \
 mkdir -p /home/webapp/webapp && \
 chown -R webapp:webapp "/home/webapp" && \
 touch /first_run.marker && \
 apt-get clean && \
 rm -rf /tmp/*

HEALTHCHECK --interval=60s --timeout=60s --start-period=60s CMD curl -f https://localhost/ || exit 1

VOLUME "/data"
EXPOSE 5432 22 80 443
CMD ["/docker-entrypoint.sh"]
