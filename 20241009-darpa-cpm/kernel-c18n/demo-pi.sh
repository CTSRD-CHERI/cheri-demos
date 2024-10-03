#!/bin/sh

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

	"${_basedir}/stop.sh" 2>/dev/null
	tmux kill-session -t demo-kernel-c18n 2>/dev/null

	check tmux new-session -d -s demo-kernel-c18n
	check tmux rename-window -t demo-kernel-c18n morello-purecap
	check tmux send-keys -t demo-kernel-c18n \
	    "${_basedir}/start.sh" Space \
	    "${_basedir}/output/cheribsd-morello-purecap.img" \
	    C-m

	tmux attach -t demo-kernel-c18n
}
main "${@}"
