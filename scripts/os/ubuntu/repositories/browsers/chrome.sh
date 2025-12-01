#!/usr/bin/env bash
#
# Installs different versions of Google Chrome
#

set -euo pipefail

AVAILABLE_CHROME_VERSIONS=(
    "stable"
    "beta"
    "unstable"
)

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Function to add the Google Chrome APT repository
add_chrome_repo() {
    log_info "Adding Google Chrome APT repository..."
    $SUDO apt-get update -y
    $SUDO apt-get install -y wget
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | $SUDO apt-key add -
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | $SUDO tee /etc/apt/sources.list.d/google-chrome.list
    $SUDO apt-get update -y
}

# Function to install a specific Chrome version
install_chrome_version() {
  local ver="$1"
  log_info "Installing Google Chrome ${ver}..."
  case "$ver" in
    stable)
      $SUDO apt-get install -y google-chrome-stable
      ;;
    beta)
      $SUDO apt-get install -y google-chrome-beta
      ;;
    unstable)
      $SUDO apt-get install -y google-chrome-unstable
      ;;
  esac
}

# Function to check if a requested version is in the list of available versions
check_version_supported() {
  local request="$1"
  for ver in "${AVAILABLE_CHROME_VERSIONS[@]}"; do
    if [[ "$ver" == "$request" ]]; then
      return 0
    fi
  done
  return 1
}