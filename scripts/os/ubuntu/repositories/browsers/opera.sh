#!/usr/bin/env bash
#
# Installs different versions of Opera
#

set -euo pipefail

AVAILABLE_OPERA_VERSIONS=(
    "stable"
    "beta"
    "developer"
)

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Function to add the Opera APT repository
add_opera_repo() {
    log_info "Adding Opera APT repository..."
    $SUDO apt-get update -y
    $SUDO apt-get install -y wget
    wget -qO- https://deb.opera.com/archive.key | $SUDO gpg --dearmor | $SUDO tee /usr/share/keyrings/opera-browser.gpg > /dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/opera-browser.gpg] https://deb.opera.com/opera-stable/ stable non-free" | $SUDO tee /etc/apt/sources.list.d/opera.list
    $SUDO apt-get update -y
}

# Function to install a specific Opera version
install_opera_version() {
  local ver="$1"
  log_info "Installing Opera ${ver}..."
  case "$ver" in
    stable)
      $SUDO apt-get install -y opera-stable
      ;;
    beta)
      $SUDO apt-get install -y opera-beta
      ;;
    developer)
      $SUDO apt-get install -y opera-developer
      ;;
  esac
}

# Function to check if a requested version is in the list of available versions
check_version_supported() {
  local request="$1"
  for ver in "${AVAILABLE_OPERA_VERSIONS[@]}"; do
    if [[ "$ver" == "$request" ]]; then
      return 0
    fi
  done
  return 1
}
