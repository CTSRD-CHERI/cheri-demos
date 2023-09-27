# nginx demo setup

## Static content

In the demo nginx s configured with the following root location:

`/usr/local/www/nginx`

To server the idemo static it should be copied to that location:

`cp -r cam /usr/local/www/nginx`

## HTTPS config

The nginx server block for the demo in configured for HTTPS
on port 443 for both IPv4 and v6.

```
listen 443;
listen [::]:443;
```

Configuration of HTTP

### demo-self-signed.conf

The demo nginx configuration file includes the file `demo-ssl-params.conf`.
This file configures the self-signed certifcate and signing key used for
the demo. Install this file as follows:

`cp demo-ssl-params.conf /usr/local/etc/nginx/`

The file `demo-ssl-params.conf` contains the following nginx config:

```
ssl_certificate /etc/ssl/certs/demo-self-signed.crt;
ssl_certificate_key /etc/ssl/private/demo-self-signed.key;
```

Install the self signed key and cert to the configured locations
as follows: 

```
cp demo-self-signed.crt /etc/ssl/certs/
cp demo-self-sgined.key /etc/ssl/private/
```

**NOTE: the demo certificate and key should provide no security and should
not be used for any other purpose than the demo.**  

### demo-ssl-params.conf

The demo nginx configuration file includes the file `demo-ssl-params.confa.`
This file configures TLS parameters to provide a realistic real-world HTTPS
server. Install this file as follows: 

`cp demo-ssl-params.conf /usr/local/etc/nginx/`
