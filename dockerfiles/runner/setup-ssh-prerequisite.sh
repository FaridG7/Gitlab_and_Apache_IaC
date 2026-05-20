#!/bin/sh
set -eu

TARGET_HOST="${1:-}"
shift || true

if [ -z "$TARGET_HOST" ]; then
  echo "Usage: $0 <target-host> [runner args...]"
  exit 1
fi

SSH_DIR="${HOME}/.ssh"
PRIVATE_KEY="${SSH_DIR}/id_rsa"
PUBLIC_KEY="${SSH_DIR}/id_rsa.pub"
KNOWN_HOSTS="${SSH_DIR}/known_hosts"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ ! -f "$PRIVATE_KEY" ]; then
  echo "Generating new SSH key pair..."
  ssh-keygen -t rsa -b 4096 -C 'gitlab-runner@example.com' -f "$PRIVATE_KEY" -N ''
fi

echo "Fetching host key for $TARGET_HOST..."
for i in {1..5}; do
  if ssh-keyscan -H "$TARGET_HOST" >> "$KNOWN_HOSTS" 2>/dev/null; then
    echo "Host key acquired."
    break
  fi
  echo "Attempt $i failed. Retrying in 2 seconds..."
  sleep 2
done

chmod 600 "$KNOWN_HOSTS"

echo "Copying public key..."
for i in $(seq 1 5); do
  if ssh-copy-id -i "$PUBLIC_KEY" "deployer@${TARGET_HOST}"; then
    break
  fi
  echo "Attempt $i failed. Retrying in 2 seconds..."
  sleep 2
done

echo "SSH setup completed for ${TARGET_HOST}."
