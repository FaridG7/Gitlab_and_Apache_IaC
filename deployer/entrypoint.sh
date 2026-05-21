#!/bin/sh

# Get the UID and GID of the gitlab-runner user
RUNNER_UID=$(id -u gitlab-runner)
RUNNER_GID=$(id -g gitlab-runner)

# Change ownership of the authorized_keys file
chown ${RUNNER_UID}:${RUNNER_GID} /home/gitlab-runner/.ssh/authorized_keys

# Execute the original command (CMD in Dockerfile or default ENTRYPOINT)
exec "$@"

