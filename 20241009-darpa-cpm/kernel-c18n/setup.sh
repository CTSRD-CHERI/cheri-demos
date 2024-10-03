#!/bin/sh -x

die() {
	echo "${*}" >&2
	exit 1
}

check() {
	"${@}"
	[ $? -eq 0 ] || die "Unable to execute: ${@} ."
}

main() {
	local _basedir

	_basedir="$(dirname "${0}")"
	check sudo pkg64c install -y curl tmux
	check fetch -o "${_basedir}/output/" https://www.cl.cam.ac.uk/~kw543/kernel-c18n/cheribsd-morello-purecap.img.xz
	sudo unxz -f "${_basedir}/output/cheribsd-morello-purecap.img.xz"
}

main "${@}"
