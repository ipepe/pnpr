#!/usr/bin/env bash

mkdir -p /opt

cp -r src/nginx-proxy-conf/ /opt/

curl https://raw.githubusercontent.com/jwilder/nginx-proxy/master/nginx.tmpl > /opt/nginx-proxy-conf/nginx.tmpl

docker run --restart=always -d -p 80:80 -p 443:443 \
    --name nginx \
    -v /opt/nginx-proxy-conf/certs:/opt \
    -v /etc/nginx/conf.d  \
    -v /etc/nginx/vhost.d \
    -v /usr/share/nginx/html \
    -v /optnginx-proxy-conf/certs:/etc/nginx/certs:ro \
    --label com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy \
    nginx

docker run --restart=always -d \
    --name nginx-gen \
    --volumes-from nginx \
    -v /opt/nginx-proxy-conf/nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    --label com.github.jrcs.letsencrypt_nginx_proxy_companion.docker_gen \
    jwilder/docker-gen \
    -notify-sighup nginx -watch -wait 5s:30s /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf

docker run --restart=always -d \
     --name nginx-letsencrypt \
     --volumes-from nginx \
     -v /optnginx-proxy-conf/certs:/etc/nginx/certs:rw \
     -v /var/run/docker.sock:/var/run/docker.sock:ro \
     jrcs/letsencrypt-nginx-proxy-companion
