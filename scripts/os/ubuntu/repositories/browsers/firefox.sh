#!/usr/bin/env bash
#
# Installs different versions of Firefox
#

set -euo pipefail

AVAILABLE_FIREFOX_VERSIONS=(
    "stable"
    "esr"
    "dev"
)

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Function to add the Mozilla APT repository for Developer Edition
add_mozilla_apt_repo() {
    log_info "Adding Mozilla APT repository for Developer Edition..."
    $SUDO install -d -m 0755 /etc/apt/keyrings
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | $SUDO tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | $SUDO tee /etc/apt/sources.list.d/mozilla.list > /dev/null
    $SUDO apt-get update -y
}

# Function to add the Mozilla Team PPA for ESR
add_mozillateam_ppa() {
    log_info "Adding Mozilla Team PPA for Firefox ESR..."
    $SUDO add-apt-repository -y ppa:mozillateam/ppa
    $SUDO apt-get update -y
}

# Function to install a specific Firefox version
install_firefox_version() {
  local ver="$1"
  log_info "Installing Firefox ${ver}..."
  case "$ver" in
    stable)
      $SUDO apt-get install -y firefox
      ;;
    esr)
      add_mozillateam_ppa
      $SUDO apt-get install -y firefox-esr
      ;;
    dev)
      add_mozilla_apt_repo
      $SUDO apt-get install -y firefox-devedition
      ;;
  esac
}

# Function to check if a requested version is in the list of available versions
check_version_supported() {
  local request="$1"
  for ver in "${AVAILABLE_FIREFOX_VERSIONS[@]}"; do
    if [[ "$ver" == "$request" ]]; then
      return 0
    fi
  done
  return 1
}
