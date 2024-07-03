#!/bin/sh

trap true SIGINT
trap true SIGTSTP

while :; do
	clear
	cat << EOF
Welcome to the CHERI demo!
Try to guess the password, or find another way :), to log in as the administrator.

EOF

	./login-unsafe
done
