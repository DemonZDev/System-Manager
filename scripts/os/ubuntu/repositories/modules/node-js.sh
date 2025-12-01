#!/usr/bin/env bash
#
# Adds NodeSource repositories for multiple Node.js versions
#

set -euo pipefail

# Sourced from: https://github.com/nodesource/distributions
# The first element of each sub-array is the version number.
# The second element is the status (LTS, Active, Maintenance, EOL).
AVAILABLE_NODE_VERSIONS=(
    "22,LTS"
    "21,Active"
    "20,LTS"
    "19,EOL"
    "18,LTS"
    "17,EOL"
    "16,LTS"
    "15,EOL"
    "14,LTS"
    "13,EOL"
    "12,LTS"
    "11,EOL"
    "10,LTS"
    "9,EOL"
    "8,LTS"
    "6,EOL"
    "4,EOL"
)

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Function to add the NodeSource repository for a specific version
install_node_repo() {
  local ver="$1"
  log_info "Adding Node.js v${ver}.x repository..."

  # Ensure curl is installed
  if ! command -v curl >/dev/null 2>&1; then
    log_info "curl not found. Installing..."
    $SUDO apt-get update -y
    $SUDO apt-get install -y curl ca-certificates gnupg
  fi

  # Add NodeSource repository
  curl -fsSL "https://deb.nodesource.com/setup_${ver}.x" | $SUDO -E bash -
}

# Function to check if a requested version is in the list of available versions
check_version_supported() {
  local request="$1"
  for ver_info in "${AVAILABLE_NODE_VERSIONS[@]}"; do
    local ver="${ver_info%,*}"
    if [[ "$ver" == "$request" ]]; then
      return 0
    fi
  done
  return 1
}