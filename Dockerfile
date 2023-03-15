FROM --platform=linux/amd64 ubuntu:20.04
MAINTAINER docker@ipepe.pl

# setup envs
ENV DEBIAN_FRONTEND=noninteractive LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# setup locale for postgres and other packages
RUN apt-get update && apt-get upgrade -y && apt-get install -y locales && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    echo 'LANG="en_US.UTF-8"' > /etc/default/locale && \
    echo 'LANGUAGE="en_US:en"' >> /etc/default/locale && \
    apt-get install --no-install-recommends -y  \
    wget nano htop git curl cron gosu psmisc \
    imagemagick \
    shared-mime-info \
    openssh-server redis \
    logrotate \
    nginx nginx-extras \
    dirmngr gnupg \
    apt-transport-https ca-certificates \
    openssl libssl-dev libreadline-dev make gcc \
    zlib1g-dev bzip2 software-properties-common \
    postgresql-client g++ openssl libssl-dev libpq-dev && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 && \
    echo deb https://oss-binaries.phusionpassenger.com/apt/passenger focal main > /etc/apt/sources.list.d/passenger.list && \
    apt-get update && apt-get install -y libnginx-mod-http-passenger passenger && \
    rm /etc/nginx/conf.d/mod-http-passenger.conf && \
    /usr/bin/passenger-config build-native-support && \
    /usr/bin/passenger-config validate-install && \
    apt-get clean && rm -rf /tmp/* /var/tmp/* && \
    groupadd -g 1000 webapp && \
    useradd -m -s /bin/bash -g webapp -u 1000 webapp && \
    echo "webapp:Password1" | chpasswd && \
    mkdir -p /home/webapp/.ssh

# setup rbenv and install ruby
USER webapp
ARG RUBY_VERSION=2.7.5
RUN git clone https://github.com/sstephenson/rbenv.git /home/webapp/.rbenv && \
    git clone https://github.com/sstephenson/ruby-build.git /home/webapp/.rbenv/plugins/ruby-build && \
    echo "export PATH=/home/webapp/.rbenv/bin:/home/webapp/.rbenv/shims:\$PATH" >> /home/webapp/.bashrc && \
    echo "export RBENV_ROOT=/home/webapp/.rbenv" >> /home/webapp/.bashrc && \
    echo "gem: --no-rdoc --no-ri" > /home/webapp/.gemrc
RUN /home/webapp/.rbenv/bin/rbenv install ${RUBY_VERSION}
RUN /home/webapp/.rbenv/bin/rbenv global ${RUBY_VERSION} && \
    /home/webapp/.rbenv/shims/gem install bundler:1.17.3 && \
    /home/webapp/.rbenv/bin/rbenv rehash

USER root

# install node
ARG NODE_MAJOR_VERSION=10
# https://github.com/nodesource/distributions/blob/master/README.md#using-debian-as-root-2
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR_VERSION}.x | bash - &&\
    apt-get install --no-install-recommends -y nodejs &&  \
    apt-get clean && rm -rf  /tmp/* /var/tmp/* && \
    npm install -g npm

# setup passenger-prometheus monitoring
COPY --from=zappi/passenger-exporter:1.0.0 /opt/app/bin/passenger-exporter /usr/local/bin/passenger-exporter
COPY --chown=webapp:webapp homefs/webapp/ /home/webapp
COPY rootfs /

# setup logrotate and systemctl
# https://www.juhomi.com/how-to-rotate-log-files-in-your-rails-application/
# https://github.com/gdraheim/docker-systemctl-replacement
RUN chmod g+x,o+x /home/webapp &&  \
    chmod +x /docker-entrypoint.rb && \
    (crontab -l; echo "0 * * * * /usr/sbin/logrotate") | crontab - && \
    /usr/local/bin/systemctl enable bootstrap.service && \
    /usr/local/bin/systemctl enable passenger-exporter.service && \
    /usr/local/bin/systemctl enable zfix-webapp-permissions.service && \
    rm -rf /etc/init.d/* && \
    rm /lib/systemd/system/nginx.service && \
    rm /lib/systemd/system/cron.service && \
    /usr/local/bin/systemctl reload nginx.service && \
    /usr/local/bin/systemctl reload cron.service && \
    /usr/local/bin/systemctl reload sidekiq.service

ARG RAILS_ENV=production
ARG NODE_ENV=production
ARG FRIENDLY_ERROR_PAGES=off

RUN echo "RUBY_VERSION=${RUBY_VERSION}" >> /etc/environment && \
    echo "NODE_VERSION=${NODE_VERSION}" >> /etc/environment && \
    echo "RAILS_ENV=${RAILS_ENV}" >> /etc/environment && \
    echo "NODE_ENV=${NODE_ENV}" >> /etc/environment && \
    echo "FRIENDLY_ERROR_PAGES=${FRIENDLY_ERROR_PAGES}" >> /etc/environment

# setup nginx
RUN sed -e "s/\${RAILS_ENV}/${RAILS_ENV}/" -e "s/\${FRIENDLY_ERROR_PAGES}/${FRIENDLY_ERROR_PAGES}/" -i /etc/nginx/sites-enabled/default
RUN nginx -t

VOLUME "/home/webapp/.ssh"
EXPOSE 22 80 9149 8080 8081 8082
CMD ["/docker-entrypoint.rb"]
