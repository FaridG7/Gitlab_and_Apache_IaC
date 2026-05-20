#!/bin/sh
set -eu

# Set home to the gitlab-runner user (so SSH keys land in the right place)
export HOME=/home/gitlab-runner

# Wait until SSH port is ready on target
echo "Waiting for SSH on $WEBSERVER_HOSTNAME:22..."
until timeout 1 bash -c "echo > /dev/tcp/$WEBSERVER_HOSTNAME/22" 2>/dev/null; do
  sleep 1
done

# Run the key‑copying script
/usr/local/bin/copy-ssh-key.sh "$WEBSERVER_HOSTNAME"

# Fix ownership (the script runs as root, so files are root-owned)
chown -R gitlab-runner:gitlab-runner "$HOME/.ssh" 2>/dev/null || true

# Now start the original process exactly as the image intends
exec /usr/bin/dumb-init /entrypoint run --user=gitlab-runner --working-directory=/home/gitlab-runner

