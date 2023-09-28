# nginx demo setup

## Static content

In the demo nginx is configured with the following root location:

`/usr/local/www/nginx`

To serve the demo static content it must be copied to that root
location:

`cp -r cam /usr/local/www/nginx`

## HTTPS config

The nginx server block for the demo in configured for HTTPS
on port 443 for both IPv4 and v6.

```
listen 443;
listen [::]:443;
```

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
cp demo-self-signed.key /etc/ssl/private/
```

**NOTE: the demo certificate and key should provide no security and should
not be used for any other purpose than the demo.**  

### demo-ssl-params.conf

The demo nginx configuration file includes the file `demo-ssl-params.conf.`
This file configures TLS parameters to provide a realistic real-world HTTPS
server. Install this file as follows: 

`cp demo-ssl-params.conf /usr/local/etc/nginx/`

#### dhparam.pem

This nginx demo ssl configuration includes a setting to increase the default
strength of Diffe-Hellan keys. To install the parameter file:

`cp dhparams.pem /usr/local/etc/nginx/`

**NOTE: the dhparams.pem file should not be used for any other purpose than
the demo.**  

