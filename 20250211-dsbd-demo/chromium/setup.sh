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

###############################################################################
# Dependencies for Chromium (is_component = false).
# 
# Dependencies to check:
# borringssl probably isn't necessary as it is embedded in nss.
#
# Missing (but not needed in the demo):
#     dav1d - patches ready but no official port
#     expat2 - no patches for this
#     harfbuzz-icu - no patches for this
#     jsoncpp - no patches for this
#     libsecret - no patches for this
#     speech-dispatch - no patches ready for this
#     speex - no patches ready for this
#     snappy - no patches ready for this
###############################################################################
CHROMIUM_RUNTIME_DEPS="at-spi2-core cairo cups dbus dbus-glib flac fontconfig freetype2 glib gtk3 harfbuzz icu libdrm libepoll-shim libevent libexif libffi libgcrypt libpci libxkbcommon libxshmfence libxml2 libxslt mesa-libs noto-basic nspr nss openh264 opus png pango re2 wayland"

if $(pkg64c check -d $CHROMIUM_RUNTIME_DEPS); then
    echo "All Chromiumn runtime dependencies found"
else
    echo "Installing Chromium runtime dependencies"
    pkg64c install -y $CHROMIUM_RUNTIME_DEPS
fi
