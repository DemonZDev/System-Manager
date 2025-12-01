#!/usr/bin/env bash
#
# Interactive Node.js installer
#

set -euo pipefail

REPO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../repositories/modules/node-js.sh"

# Load functions from repo script
# shellcheck source=/dev/null
. "$REPO_SCRIPT"

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

echo
log_info "Select Node.js version to install:"
echo

index=1
for ver_info in "${AVAILABLE_NODE_VERSIONS[@]}"; do
  ver="${ver_info%,*}"
  status="${ver_info#*,}"
  printf "%2d) v%-7s (%s)\n" "$index" "${ver}.x" "$status"
  index=$((index+1))
done

echo
read -rp "Enter number [1-$((${#AVAILABLE_NODE_VERSIONS[@]}))]: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
  log_error "Invalid input. Please enter a number."
  exit 1
fi

if (( choice < 1 || choice > ${#AVAILABLE_NODE_VERSIONS[@]} )); then
  log_error "Choice out of range."
  exit 1
fi

SELECTED_VERSION_INFO="${AVAILABLE_NODE_VERSIONS[$((choice-1))]}"
NODE_VERSION="${SELECTED_VERSION_INFO%,*}"

echo
log_info "Installing Node.js v${NODE_VERSION}.x ..."
echo

if check_version_supported "$NODE_VERSION"; then
  install_node_repo "$NODE_VERSION"
else
  log_error "Version not supported."
  exit 1
fi

$SUDO apt-get update -y
$SUDO apt-get install -y nodejs

echo
log_info "Node.js successfully installed."
log_info "node: $(node -v)"
log_info "npm : $(npm -v)"