#!/usr/bin/env bash
#
# Interactive Firefox installer
#

set -euo pipefail

REPO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../repositories/browsers/firefox.sh"

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
log_info "Select Firefox version to install:"
echo

index=1
for ver in "${AVAILABLE_FIREFOX_VERSIONS[@]}"; do
  printf "%2d) Firefox %s\n" "$index" "${ver}"
  index=$((index+1))
done

echo
read -rp "Enter number [1-$((${#AVAILABLE_FIREFOX_VERSIONS[@]}))]: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
  log_error "Invalid input. Please enter a number."
  exit 1
fi

if (( choice < 1 || choice > ${#AVAILABLE_FIREFOX_VERSIONS[@]} )); then
  log_error "Choice out of range."
  exit 1
fi

FIREFOX_VERSION="${AVAILABLE_FIREFOX_VERSIONS[$((choice-1))]}"

echo
log_info "Installing Firefox ${FIREFOX_VERSION}..."
echo

if check_version_supported "$FIREFOX_VERSION"; then
  install_firefox_version "$FIREFOX_VERSION"
else
  log_error "Version not supported."
  exit 1
fi

echo
log_info "Firefox ${FIREFOX_VERSION} successfully installed."

