#!/bin/sh

DEFAULT_USER="readonly"
DEFAULT_PASSWORD="$(cat ~/.config/ctsrd-jenkins-readonly-user.txt 2>/dev/null)"
DEFAULT_URL="https://ctsrd-build.cl.cam.ac.uk/job/CheriBSD-pipeline/job/kernel-c18n/lastSuccessfulBuild/artifact/artifacts-morello-purecap/cheribsd-morello-purecap.img.xz"

die() {
	echo "${*}" >&2
	exit 1
}

usage() {
	cat << EOF
usage: ${0} [url]

default url: ${DEFAULT_URL}
EOF
	exit 1
}

main() {
	local _arg _file _url

	if [ -z "${DEFAULT_PASSWORD}" ]; then
		die "Store a password for the Jenkins readonly user in ~/.config/ctsrd-jenkins-readonly-user.txt ."
	fi

	which -s curl
	[ $? -eq 0 ] || die "Install curl first: pkg64c install curl ."

	while getopts "h" _arg; do
		case "${_arg}" in
		h)
			usage
			;;
		*)
			usage
			;;
		esac
	done

	_url="${1}"
	if [ -z "${_url}" ]; then
		_url="${DEFAULT_URL}"
	fi

	mkdir -p output
	[ $? -eq 0 ] || die "Unable to create output/."
	_file="output/$(echo "${_url}" | tr '/' '\n' | tail -n 1)"

	echo "Fetching a file from '${_url}' into '${_file}'."
	echo
	curl \
	    -u "${DEFAULT_USER}:${DEFAULT_PASSWORD}" \
	    "${_url}" \
	    --output "${_file}"
	[ $? -eq 0 ] || die "Unable to fetch the file."

	echo
	echo "Decompressing the file '${_file}'."
	unxz -f "${_file}"
	[ $? -eq 0 ] || die "Unable to decompress the file."
}

main "${@}"
