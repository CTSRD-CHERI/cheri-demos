#!/bin/sh

pkg64c install -y nginx
if [ ! -e /usr/local/etc/nginx ]; then
    ln -s /usr/local/etc/nginx-cheri /usr/local/etc/nginx
fi
if [ -e /usr/local/www/dsbd-demo ]; then
    rm -r /usr/local/www/dsbd-demo
fi
cp nginx.conf /usr/local/etc/nginx-cheri/nginx.conf
wget -r -k -p --no-parent https://www.cl.cam.ac.uk/research/security/ctsrd/cheri/
cp -r www.cl.cam.ac.uk /usr/local/www/dsbd-demo
rm -r www.cl.cam.ac.uk
cp -r exploits-demo /usr/local/www/exploits

sysrc nginx_enable=YES
service nginx start
