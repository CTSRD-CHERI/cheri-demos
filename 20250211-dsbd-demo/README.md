# DSbD Showcase Demo

## Morello box setup

The morello-desktop directory contains scripts to set-up morello boxes.

### Nginx setup
The nginx directory contains scripts to set up the nginx package and environment.

To install and setup the base nginx configuration run:

```
sudo ./setup.sh
```

This will clone the www.cl.cam.ac.uk CHERI pages to be served statically from this machine.
The root www directory is placed at /usr/local/www/dsbd-demo.
It should be possible to access the static pages at `http://localhost`.
