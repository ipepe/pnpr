#!/usr/bin/env bash

mkdir -p /opt

cp -r src/nginx-proxy-conf/ /opt/

docker run --restart=unless-stopped -d -p 80:80 -p 443:443 \
    --name nginx \
    -v /opt/nginx-proxy-conf/certs:/opt \
    -v /etc/nginx/conf.d  \
    -v /etc/nginx/vhost.d \
    -v /usr/share/nginx/html \
    -v /path/to/certs:/etc/nginx/certs:ro \
    --label com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy \
    nginx

docker run --restart=unless-stopped -d \
    --name nginx-gen \
    --volumes-from nginx \
    -v /opt/nginx-proxy/nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    --label com.github.jrcs.letsencrypt_nginx_proxy_companion.docker_gen \
    jwilder/docker-gen \
    -notify-sighup nginx -watch -wait 5s:30s /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf

docker run --restart=unless-stopped -d \
     --name nginx-letsencrypt \
     --volumes-from nginx \
     -v /path/to/certs:/etc/nginx/certs:rw \
     -v /var/run/docker.sock:/var/run/docker.sock:ro \
     jrcs/letsencrypt-nginx-proxy-companion


sudo docker run -d --name whoami -h whoami -e VIRTUAL_HOST=whoami.ipepe.pl -e LETSENCRYPT_HOST=whoami.ipepe.pl -e LETSENCRYPT_EMAIL=letsencrypt@ipepe.pl --restart=unless-stopped -i -t -P jwilder/whoami
sudo docker run -d --name whoami2 -h whoami2 -e VIRTUAL_HOST=whoami2.ipepe.pl -e LETSENCRYPT_HOST=whoami2.ipepe.pl -e LETSENCRYPT_EMAIL=letsencrypt@ipepe.pl --restart=unless-stopped -i -t -P jwilder/whoami