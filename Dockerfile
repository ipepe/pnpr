#FROM golang:1.9.4 as prometheus-exporter-builder
#
#RUN mkdir -p /go/src
#WORKDIR /go/src
#RUN go get github.com/prometheus/promu
#RUN wget https://raw.githubusercontent.com/Intellection/passenger-exporter/master/.promu.yml
#RUN wget https://raw.githubusercontent.com/Intellection/passenger-exporter/master/passenger_exporter.go
#RUN promu build

FROM --platform=linux/amd64 ubuntu:22.04
MAINTAINER docker@ipepe.pl

# setup args
ARG NODE_VERSION=10.24.1
ARG RUBY_VERSION=2.3.8
ARG RAILS_ENV=staging
ARG NODE_ENV=staging
ARG FRIENDLY_ERROR_PAGES=on
ARG WITH_SUDO=true

# setup envs
ENV DEBIAN_FRONTEND=noninteractive LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
RUN echo "RUBY_VERSION=${RUBY_VERSION}" >> /etc/environment && \
    echo "NODE_VERSION=${NODE_VERSION}" >> /etc/environment && \
    echo "RAILS_ENV=${RAILS_ENV}" >> /etc/environment && \
    echo "NODE_ENV=${NODE_ENV}" >> /etc/environment && \
    echo "FRIENDLY_ERROR_PAGES=${FRIENDLY_ERROR_PAGES}" >> /etc/environment && \
    echo "WITH_SUDO=${WITH_SUDO}" >> /etc/environment

# setup locale for postgres and other packages
RUN apt-get update && apt-get install -y locales && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    echo 'LANG="en_US.UTF-8"' > /etc/default/locale && \
    echo 'LANGUAGE="en_US:en"' >> /etc/default/locale

# install prerequisities for ruby, nodejs and others
RUN apt-get update && apt-get install -y  \
    wget nano htop git curl cron gosu \
    imagemagick \
    openssh-server redis \
    logrotate \
    nginx nginx-extras \
    dirmngr gnupg \
    apt-transport-https ca-certificates \
    openssl libssl-dev libreadline-dev make gcc \
    zlib1g-dev bzip2 software-properties-common

# install passenger
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
RUN echo deb https://oss-binaries.phusionpassenger.com/apt/passenger jammy main > /etc/apt/sources.list.d/passenger.list
RUN apt-get update && apt-get install -y libnginx-mod-http-passenger passenger
RUN rm /etc/nginx/conf.d/mod-http-passenger.conf
RUN /usr/bin/passenger-config build-native-support
RUN /usr/bin/passenger-config validate-install

# create webapp user
RUN groupadd -g 1000 webapp && \
    useradd -m -s /bin/bash -g webapp -u 1000 webapp && \
    echo "webapp:Password1" | chpasswd && \
    mkdir -p /home/webapp/.ssh

## add webapp user to sudo
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
    echo "gem: --no-rdoc --no-ri" > /home/webapp/.gemrc
RUN /home/webapp/.rbenv/bin/rbenv install ${RUBY_VERSION} && \
    /home/webapp/.rbenv/bin/rbenv global ${RUBY_VERSION} && \
    /home/webapp/.rbenv/shims/gem update --system && \
    /home/webapp/.rbenv/shims/gem install bundler && \
    /home/webapp/.rbenv/bin/rbenv rehash

# install nodenv
RUN git clone https://github.com/nodenv/nodenv.git /home/webapp/.nodenv && \
    git clone https://github.com/nodenv/node-build.git /home/webapp/.nodenv/plugins/node-build
RUN echo "export PATH=/home/webapp/.nodenv/bin:/home/webapp/.nodenv/shims:${PATH}" >> /home/webapp/.bashrc && \
    echo "export NODENV_ROOT=/home/webapp/.nodenv" >> /home/webapp/.bashrc
RUN /home/webapp/.nodenv/bin/nodenv install ${NODE_VERSION} && \
    /home/webapp/.nodenv/bin/nodenv global ${NODE_VERSION} && \
    /home/webapp/.nodenv/bin/nodenv rehash


RUN echo "source /etc/environment" >> /home/webapp/.bashrc
USER root
RUN echo "source /etc/environment" >> /root/.bashrc

# setup logrotate
# https://www.juhomi.com/how-to-rotate-log-files-in-your-rails-application/
COPY src/logrotate_rails_logrotate.conf /etc/logrotate.d/rails_logrotate.conf
RUN (crontab -l; echo "0 * * * * /usr/sbin/logrotate") | crontab -

# setup nginx
COPY src/nginx/nginx.conf /etc/nginx/
COPY src/nginx/webapp.conf /etc/nginx/sites-enabled/default
RUN sed -e "s/\${RAILS_ENV}/${RAILS_ENV}/" -e "s/\${FRIENDLY_ERROR_PAGES}/${FRIENDLY_ERROR_PAGES}/" -i /etc/nginx/sites-enabled/default
RUN nginx -t

# setup passenger-prometheus monitoring
COPY src/nginx/monitoring.conf /etc/nginx/sites-enabled/
COPY --from=zappi/passenger-exporter /usr/local/bin/passenger-exporter /usr/local/bin/passenger-exporter
RUN mkdir -p /monitoring/public
RUN nginx -t

## install docker-entrypoint and cleanup whole image with final setups
COPY src/docker-entrypoint.sh /
RUN chmod 700 /docker-entrypoint.sh && apt-get clean && rm -rf /tmp/*

VOLUME "/home/webapp/webapp"
VOLUME "/home/webapp/.ssh"
EXPOSE 22 80 443 8080 8443 10254 9149
CMD ["/docker-entrypoint.sh"]
