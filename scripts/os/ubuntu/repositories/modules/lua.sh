#!/usr/bin/env bash
#
# Installs multiple Lua versions
#

set -euo pipefail

# This list is a general guide and might not be 100% accurate for all Ubuntu versions.
AVAILABLE_LUA_VERSIONS=(
    "5.4"
    "5.3"
    "5.2"
    "5.1"
)

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Function to install a specific Lua version
install_lua_version() {
  local ver="$1"
  log_info "Installing Lua ${ver}..."
  $SUDO apt-get update -y
  $SUDO apt-get install -y "lua${ver}" "liblua${ver}-dev"
}

# Function to check if a requested version is in the list of available versions
check_version_supported() {
  local request="$1"
  for ver in "${AVAILABLE_LUA_VERSIONS[@]}"; do
    if [[ "$ver" == "$request" ]]; then
      return 0
    fi
  done
  return 1
}
