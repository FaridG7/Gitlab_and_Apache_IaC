#!/usr/bin/env bash
set -Eeuo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
RUNNER_KEY_DIR="./volumes/runner"
DEPLOYER_KEY_DIR="./volumes/deployer"
RUNNER_KEY="${RUNNER_KEY_DIR}/key"
DEPLOYER_KEY="${DEPLOYER_KEY_DIR}/key"
DEPLOYER_AUTHORIZED_KEYS="${DEPLOYER_KEY_DIR}/authorized_keys"
RUNNER_KNOWN_HOSTS="${RUNNER_KEY_DIR}/known_hosts"
ENV_FILE=".env"

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
log() {
  printf '[INFO] %s\n' "$*"
}

error() {
  printf '[ERROR] %s\n' "$*" >&2
}

die() {
  error "$*"
  exit 1
}

load_env_file() {
  [[ -f "$ENV_FILE" ]] || return 0

  while IFS='=' read -r key value; do
    # Skip empty lines and comments
    [[ -z "${key//[[:space:]]/}" ]] && continue
    [[ "$key" =~ ^[[:space:]]*# ]] && continue

    # Trim whitespace around key
    key="${key#"${key%%[![:space:]]*}"}"
    key="${key%"${key##*[![:space:]]}"}"

    # Skip malformed lines
    [[ -z "$key" || "$key" != [A-Za-z_]*([A-Za-z0-9_]) ]] && continue

    # Trim surrounding quotes from value if present
    value="${value#\"}"
    value="${value%\"}"

    export "$key=$value"
  done < "$ENV_FILE"
}

generate_ssh_keypair() {
  local key_path="$1"
  local comment="$2"

  mkdir -p "$(dirname "$key_path")"

  if [[ -f "$key_path" || -f "${key_path}.pub" ]]; then
    log "SSH key already exists at ${key_path}; reusing existing key."
    return 0
  fi

  ssh-keygen -t ed25519 -C "$comment" -N "" -f "$key_path" >/dev/null
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
load_env_file

: "${DEPLOYER_HOSTNAME:?Error: DEPLOYER_HOSTNAME environment variable is not set.}"

mkdir -p "$RUNNER_KEY_DIR" "$DEPLOYER_KEY_DIR"

log "Generating runner SSH key..."
generate_ssh_keypair "$RUNNER_KEY" "gitlab-runner"

log "Generating deployer SSH key..."
generate_ssh_keypair "$DEPLOYER_KEY" "deployer"

log "Generating deployer authorized_keys..."
cp "${RUNNER_KEY}.pub" "$DEPLOYER_AUTHORIZED_KEYS"

log "Generating runner known_hosts..."
if [[ ! -f "${DEPLOYER_KEY}.pub" ]]; then
  die "Public key file not found: ${DEPLOYER_KEY}.pub"
fi

# known_hosts format: host keytype key
read -r key_type key_data < <(awk '{print $1, $2}' "${DEPLOYER_KEY}.pub")
printf '%s %s %s\n' "$DEPLOYER_HOSTNAME" "$key_type" "$key_data" > "$RUNNER_KNOWN_HOSTS"

log "Success: ${RUNNER_KNOWN_HOSTS} has been generated."

