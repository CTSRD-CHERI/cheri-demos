#!/bin/sh

pkg64c install nginx
ln -s /usr/local/etc/nginx-cheri /usr/local/etc/nginx
cp nginx.conf /usr/local/etc/nginx-cheri/nginx.conf
wget -r -k -p --no-parent https://www.cl.cam.ac.uk/research/security/ctsrd/cheri/
cp -r www.cl.cam.ac.uk /usr/local/www/dsbd-demo
rm www.cl.cam.ac.uk

sysrc nginx_enable=YES
service nginx start
