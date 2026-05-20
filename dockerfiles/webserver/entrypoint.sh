#!/bin/sh
set -e
echo "starting ssh daemon"
ssh-keygen -A
/usr/sbin/sshd
exec "$@"
