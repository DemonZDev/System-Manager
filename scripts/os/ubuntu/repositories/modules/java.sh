#!/usr/bin/env bash
#
# Installs multiple OpenJDK versions
#

set -euo pipefail

# This list is a general guide and might not be 100% accurate for all Ubuntu versions.
AVAILABLE_JAVA_VERSIONS=(
    "21"
    "17"
    "11"
    "8"
)

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Function to install a specific OpenJDK version
install_java_version() {
  local ver="$1"
  log_info "Installing OpenJDK ${ver}..."
  $SUDO apt-get update -y
  $SUDO apt-get install -y "openjdk-${ver}-jdk"
}

# Function to check if a requested version is in the list of available versions
check_version_supported() {
  local request="$1"
  for ver in "${AVAILABLE_JAVA_VERSIONS[@]}"; do
    if [[ "$ver" == "$request" ]]; then
      return 0
    fi
  done
  return 1
}
