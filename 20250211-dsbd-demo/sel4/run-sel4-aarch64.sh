#!/bin/sh

SEL4_IMAGE_PATH=${SEL4_IMAGE_PATH:-.}

sudo bhyve -c 1 -m 1g \
     -s 0,hostbridge \
     -s 2,virtio-blk,${SEL4_IMAGE_PATH}/sel4test-bhyve-scanf-release-image-aarch64-v0  \
     -G 1234 -S \
     -o bootrom=/usr/local/share/u-boot/u-boot-bhyve-arm64/u-boot.bin \
     -o console=stdio \
     sel4aarch64
