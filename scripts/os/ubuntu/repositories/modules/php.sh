#!/usr/bin/env bash
#
# Adds the ondrej/php PPA for multiple PHP versions
#

set -euo pipefail

# Sourced from: https://launchpad.net/~ondrej/+archive/ubuntu/php
# This list is a general guide and might not be 100% accurate for all Ubuntu versions.
AVAILABLE_PHP_VERSIONS=(
    "8.3"
    "8.2"
    "8.1"
    "8.0"
    "7.4"
    "7.3"
    "7.2"
    "7.1"
    "7.0"
    "5.6"
)

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Function to add the ondrej/php PPA
add_php_ppa() {
    log_info "Adding ondrej/php PPA..."
    $SUDO apt-get update -y
    $SUDO apt-get install -y software-properties-common
    $SUDO add-apt-repository -y ppa:ondrej/php
    $SUDO apt-get update -y
}

# Function to install a specific PHP version and common extensions
install_php_version() {
  local ver="$1"
  log_info "Installing PHP ${ver} and common extensions..."
  $SUDO apt-get install -y "php${ver}" "php${ver}-cli" "php${ver}-fpm" "php${ver}-mysql" "php${ver}-xml" "php${ver}-mbstring" "php${ver}-zip" "php${ver}-gd" "php${ver}-curl"
}

# Function to check if a requested version is in the list of available versions
check_version_supported() {
  local request="$1"
  for ver in "${AVAILABLE_PHP_VERSIONS[@]}"; do
    if [[ "$ver" == "$request" ]]; then
      return 0
    fi
  done
  return 1
}
