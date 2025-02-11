#!/bin/sh

sudo bhyve -c 1 -m 1g \
     -s 0,hostbridge \
     -s 2,virtio-blk,${1} \
     -G 1235 -S \
     -o bootrom=/usr/local/share/u-boot/u-boot-bhyve-arm64/u-boot.bin \
     -o console=stdio \
     sel4cheri
