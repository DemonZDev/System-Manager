#!/usr/bin/env bash
#
# Interactive Opera installer
#

set -euo pipefail

REPO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../repositories/browsers/opera.sh"

# Load functions from repo script
# shellcheck source=/dev/null
. "$REPO_SCRIPT"

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

add_opera_repo

echo
log_info "Select Opera version to install:"
echo

index=1
for ver in "${AVAILABLE_OPERA_VERSIONS[@]}"; do
  printf "%2d) Opera %s\n" "$index" "${ver}"
  index=$((index+1))
done

echo
read -rp "Enter number [1-$((${#AVAILABLE_OPERA_VERSIONS[@]}))]: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
  log_error "Invalid input. Please enter a number."
  exit 1
fi

if (( choice < 1 || choice > ${#AVAILABLE_OPERA_VERSIONS[@]} )); then
  log_error "Choice out of range."
  exit 1
fi

OPERA_VERSION="${AVAILABLE_OPERA_VERSIONS[$((choice-1))]}"

echo
log_info "Installing Opera ${OPERA_VERSION}..."
echo

if check_version_supported "$OPERA_VERSION"; then
  install_opera_version "$OPERA_VERSION"
else
  log_error "Version not supported."
  exit 1
fi

echo
log_info "Opera ${OPERA_VERSION} successfully installed."

