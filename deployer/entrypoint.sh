#!/bin/sh
chown -R gitlab-runner:gitlab-runner /home/gitlab-runner/.ssh
chmod 700 /home/gitlab-runner/.ssh
chmod 600 /home/gitlab-runner/.ssh/* 2>/dev/null || true

chown -R root:deployers /home/gitlab-runner/www && \
	chmod 2770 /home/gitlab-runner/www

# Execute the main command
exec "$@"

