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

echo "DSbD Showcase 2025-02-11 Chromium Demo"

echo "Checking Chromium runtime dependencies"

# Missing:
# dav1d - patches ready but no official port
# snappy - no patches ready for this
CHROMIUM_RUNTIME_DEPS= \
    at-spi2-core \
    boringssl \
    cairo \
    flac \
    gtk3 \
    fontconfig \
    freetype \
    harfbuzz \
    icu \
    libxml2 \
    libxlst \
    mesa-libs \
    mesa-dria \
    noto-basic \
    nspr \
    nss \
    openh264 \
    opus \
    png \
    pango

if $(pkg64c check -d $CHROMIUM_RUNTIME_DEPS); then
    echo "All Chromiumn runtime dependencies found"
else
    echo "Installing Chromium runtime dependencies"
    pkg64c install $(CHROMIUM_RUNTIME_DEPS)
fi
