#!/usr/bin/env bash
#
# Interactive MongoDB installer
#

set -euo pipefail

REPO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../repositories/databases/mongodb.sh"

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
log_info "Select MongoDB version to install:"
echo

index=1
for ver in "${AVAILABLE_MONGODB_VERSIONS[@]}"; do
  printf "%2d) MongoDB %s\n" "$index" "${ver}"
  index=$((index+1))
done

echo
read -rp "Enter number [1-$((${#AVAILABLE_MONGODB_VERSIONS[@]}))]: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
  log_error "Invalid input. Please enter a number."
  exit 1
fi

if (( choice < 1 || choice > ${#AVAILABLE_MONGODB_VERSIONS[@]} )); then
  log_error "Choice out of range."
  exit 1
fi

MONGODB_VERSION="${AVAILABLE_MONGODB_VERSIONS[$((choice-1))]}"

echo
log_info "Installing MongoDB ${MONGODB_VERSION}..."
echo

if check_version_supported "$MONGODB_VERSION"; then
  add_mongodb_repo "$MONGODB_VERSION"
  install_mongodb_version "$MONGODB_VERSION"
else
  log_error "Version not supported."
  exit 1
fi

log_info "Starting and enabling mongod service..."
$SUDO systemctl start mongod
$SUDO systemctl enable mongod

echo
log_info "MongoDB ${MONGODB_VERSION} successfully installed and started."
log_info "You can check the status of the mongod service with the command:"
log_info "systemctl status mongod"
