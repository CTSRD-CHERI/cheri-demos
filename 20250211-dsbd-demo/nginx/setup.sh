#!/bin/sh

pkg64c install -y nginx
if [ ! -e /usr/local/etc/nginx ]; then
    ln -s /usr/local/etc/nginx-cheri /usr/local/etc/nginx
fi
cp nginx.conf /usr/local/etc/nginx-cheri/nginx.conf
if [ ! -d /usr/local/www/dsbd-demo ]; then
    wget -r -k -p --no-parent https://www.cl.cam.ac.uk/research/security/ctsrd/cheri/
    mv www.cl.cam.ac.uk /usr/local/www/dsbd-demo
fi
cp -r exploits-demo /usr/local/www/exploits

sysrc nginx_enable=YES
service nginx start
