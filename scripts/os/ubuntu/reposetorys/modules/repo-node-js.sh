#!/usr/bin/env bash
#
# Adds NodeSource repositories for multiple Node.js versions
#

set -euo pipefail

AVAILABLE_NODE_VERSIONS=(
  "0" "4" "6" "8" "10" "12" "14" "16" "18" "19" "20" "21" "22" "23" "24" "25"
)

echo "Preparing Node.js repository..."

$SUDO apt-get update -y
$SUDO apt-get install -y curl ca-certificates gnupg

install_node_repo() {
  local ver="$1"
  echo "Adding Node.js v${ver}.x repository..."
  curl -fsSL "https://deb.nodesource.com/setup_${ver}.x" | $SUDO -E bash -
}

check_version_supported() {
  local request="$1"
  for ver in "${AVAILABLE_NODE_VERSIONS[@]}"; do
    if [[ "$ver" == "$request" ]]; then
      return 0
    fi
  done
  return 1
}
