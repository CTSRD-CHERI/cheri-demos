#!/bin/sh

DEFAULT_IMG="output/cheribsd-morello-purecap.img"
DEFAULT_NAME="kernel-c18n"
DEFAULT_PORT="3000"

usage() {
	cat << EOF
usage: ${0} [img]

default img: ${DEFAULT_IMG}
EOF
	exit 1
}

main() {
	local _img

	_img="${1}"
	if [ -z "${_img}" ]; then
		_img="${DEFAULT_IMG}"
	fi

	sudo bhyve \
	    -G "${DEFAULT_PORT}" \
	    -m 1G \
	    -c 1 \
	    -s 0,hostbridge \
	    -s "2,virtio-blk,${_img}" \
	    -o bootrom=/usr/local/share/u-boot/u-boot-bhyve-arm64/u-boot.bin \
	    -o console=stdio \
	    "${DEFAULT_NAME}"
}

main "${@}"
