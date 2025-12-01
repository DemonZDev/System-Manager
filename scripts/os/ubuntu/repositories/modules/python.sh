#!/usr/bin/env bash
#
# Adds the deadsnakes PPA for multiple Python versions
#

set -euo pipefail

# Sourced from: https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa
# The first element of each sub-array is the version number.
# The second element is the status (Available, Not Available for this Ubuntu version).
# This list is a general guide and might not be 100% accurate for all Ubuntu versions.
AVAILABLE_PYTHON_VERSIONS=(
    "3.13,Available"
    "3.12,Available"
    "3.11,Available"
    "3.10,Available"
    "3.9,Available"
    "3.8,Available"
    "3.7,Available"
    "3.6,EOL"
    "3.5,EOL"
    "2.7,EOL"
)

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Function to add the deadsnakes PPA
add_deadsnakes_ppa() {
    log_info "Adding deadsnakes PPA..."
    $SUDO apt-get update -y
    $SUDO apt-get install -y software-properties-common
    $SUDO add-apt-repository -y ppa:deadsnakes/ppa
    $SUDO apt-get update -y
}

# Function to install a specific Python version
install_python_version() {
  local ver="$1"
  log_info "Installing Python ${ver}..."
  $SUDO apt-get install -y "python${ver}" "python${ver}-dev" "python${ver}-venv"
}

# Function to check if a requested version is in the list of available versions
check_version_supported() {
  local request="$1"
  for ver_info in "${AVAILABLE_PYTHON_VERSIONS[@]}"; do
    local ver="${ver_info%,*}"
    if [[ "$ver" == "$request" ]]; then
      return 0
    fi
  done
  return 1
}
