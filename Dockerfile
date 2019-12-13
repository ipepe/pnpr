FROM ubuntu:16.04
MAINTAINER docker@ipepe.pl

# setup args
ARG RUBY_VERSION=2.5.7
ARG RAILS_ENV=production
ARG FRIENDLY_ERROR_PAGES=off
ARG WITH_SUDO=false

# setup envs
ENV PGDATA=/data/db DEBIAN_FRONTEND=noninteractive LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
RUN echo "RUBY_VERSION=${RUBY_VERSION}" >> /etc/environment && \
    echo "RAILS_ENV=${RAILS_ENV}" >> /etc/environment && \
    echo "FRIENDLY_ERROR_PAGES=${FRIENDLY_ERROR_PAGES}" >> /etc/environment && \
    echo "WITH_SUDO=${WITH_SUDO}" >> /etc/environment

RUN cat /etc/environment
# setup locale for postgres and other packages
RUN apt-get update && apt-get install -y locales && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    echo 'LANG="en_US.UTF-8"' > /etc/default/locale && \
    echo 'LANGUAGE="en_US:en"' >> /etc/default/locale

# install prerequisities for ruby, postgres, redis, nodejs and others
RUN apt-get update && apt-get install -y \
    git make gcc g++ nodejs npm openssl libssl-dev curl libpq-dev \
    cron libreadline-dev libmagickwand-dev imagemagick wget nano htop \
    openssh-server apt-utils libjpeg-dev libpng-dev redis-server && \
    npm install -g n && n 8 && npm install -g npm && \
    ln -s /usr/bin/nodejs /usr/bin/node

# install postgres 10
RUN curl -o /usr/local/bin/gosu -SL 'https://github.com/tianon/gosu/releases/download/1.1/gosu' && \
    chmod 700 /usr/local/bin/gosu && \
	echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" >> /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && apt-get install -y postgresql-10 postgresql-contrib-10 postgresql-client-10 && \
    mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql && \
    rm -rf /var/lib/postgresql/10/main

# install and configure nginx and passenger
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7 && \
    apt-get update && apt-get install -y apt-transport-https ca-certificates && \
    echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main" > /etc/apt/sources.list.d/passenger.list && \
    apt-get update && apt-get install -y nginx-extras passenger
RUN passenger-config build-native-support

COPY src/nginx.conf /etc/nginx/
COPY src/webapp.conf /etc/nginx/sites-enabled/default
RUN sed -e "s/\${RAILS_ENV}/${RAILS_ENV}/" -e "s/\${FRIENDLY_ERROR_PAGES}/${FRIENDLY_ERROR_PAGES}/" -i /etc/nginx/sites-enabled/default

# create webapp user
RUN groupadd -g 1000 webapp && \
    useradd -m -s /bin/bash -g webapp -u 1000 webapp && \
    echo "webapp:Password1" | chpasswd

# add webapp user to sudo
RUN if [ $WITH_SUDO = "true" ] ; then \
        apt-get update && \
        apt-get install -y sudo && \
        usermod -a -G sudo webapp && \
        echo "webapp ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/00_webapp_sudo_rules \
    ; fi

# setup rbenv and install ruby
USER webapp
RUN git clone https://github.com/sstephenson/rbenv.git /home/webapp/.rbenv && \
    git clone https://github.com/sstephenson/ruby-build.git /home/webapp/.rbenv/plugins/ruby-build && \
    echo "export PATH=/home/webapp/.rbenv/bin:/home/webapp/.rbenv/shims:${PATH}" >> /home/webapp/.bashrc && \
    echo "export RBENV_ROOT=/home/webapp/.rbenv" >> /home/webapp/.bashrc && \
    echo "export RAILS_ENV=${RAILS_ENV}" >> /home/webapp/.bashrc && \
    echo "gem: --no-rdoc --no-ri" > /home/webapp/.gemrc && \
    /home/webapp/.rbenv/bin/rbenv install ${RUBY_VERSION} && \
    /home/webapp/.rbenv/bin/rbenv global ${RUBY_VERSION} && \
    /home/webapp/.rbenv/shims/gem install bundler && \
    /home/webapp/.rbenv/bin/rbenv rehash
USER root

# install docker-entrypoint and cleanup whole image with final setups
RUN mkdir -p /home/webapp/webapp /home/webapp/.ssh && \
    chown -R webapp:webapp "/home/webapp" && \
    apt-get clean && \
    rm -rf /tmp/*

COPY src/docker-entrypoint.sh /
RUN chmod 700 /docker-entrypoint.sh

VOLUME "/data"
EXPOSE 5432 22 80
CMD ["/docker-entrypoint.sh"]
