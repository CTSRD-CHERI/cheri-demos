#!/bin/sh

if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi

if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
else
    real_user=$(whoami)
fi

echo "Checking Chromium runtime dependencies"

CHROMIUM_RUNTIME_DEPS= at-spi2-core \
    boringssl \
    cairo \
    gtk3 \
    harfbuzz \
    mesa-libs \
    mesa-dria \
    nspr \
    nss \
    pango

if $(pkg64c check -d $CHROMIUM_RUNTIME_DEPS); then
    echo "All Chromiumn runtime dependencies found"
else
    echo "Installing Chromium runtime dependencies"
    pkg64c instal $(CHROMIUM_RUNTIME_DEPS
fi
