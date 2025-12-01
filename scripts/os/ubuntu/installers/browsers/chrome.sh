#!/usr/bin/env bash
#
# Interactive Google Chrome installer
#

set -euo pipefail

REPO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../repositories/browsers/chrome.sh"

# Load functions from repo script
# shellcheck source=/dev/null
. "$REPO_SCRIPT"

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

add_chrome_repo

echo
log_info "Select Google Chrome version to install:"
echo

index=1
for ver in "${AVAILABLE_CHROME_VERSIONS[@]}"; do
  printf "%2d) Google Chrome %s\n" "$index" "${ver}"
  index=$((index+1))
done

echo
read -rp "Enter number [1-$((${#AVAILABLE_CHROME_VERSIONS[@]}))]: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
  log_error "Invalid input. Please enter a number."
  exit 1
fi

if (( choice < 1 || choice > ${#AVAILABLE_CHROME_VERSIONS[@]} )); then
  log_error "Choice out of range."
  exit 1
fi

CHROME_VERSION="${AVAILABLE_CHROME_VERSIONS[$((choice-1))]}"

echo
log_info "Installing Google Chrome ${CHROME_VERSION}..."
echo

if check_version_supported "$CHROME_VERSION"; then
  install_chrome_version "$CHROME_VERSION"
else
  log_error "Version not supported."
  exit 1
fi

echo
log_info "Google Chrome ${CHROME_VERSION} successfully installed."
