#!/usr/bin/env bash
#
# Installs and manages Go versions using goenv
#

set -euo pipefail

# This is a partial list. `goenv install -l` provides a complete list.
AVAILABLE_GO_VERSIONS=(
    "1.22.0"
    "1.21.5"
    "1.20.12"
    "1.19.13"
    "1.18.10"
)

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Function to install goenv
install_goenv() {
    log_info "Installing goenv..."
    if [ ! -d "$HOME/.goenv" ]; then
        git clone https://github.com/syndbg/goenv.git ~/.goenv
    fi
    # Add goenv to the path for the current session
    export GOENV_ROOT="$HOME/.goenv"
    export PATH="$GOENV_ROOT/bin:$PATH"
    eval "$(goenv init -)"
}

# Function to install a specific Go version
install_go_version() {
  local version="$1"
  log_info "Installing Go ${version}..."
  goenv install "$version"
}

# Function to set the global Go version
set_global_go_version() {
  local version="$1"
  log_info "Setting global Go version to ${version}..."
  goenv global "$version"
}

# Function to check if a requested version is in the list of available versions
check_version_supported() {
  local request="$1"
  for version in "${AVAILABLE_GO_VERSIONS[@]}"; do
    if [[ "$version" == "$request" ]]; then
      return 0
    fi
  done
  # For go, we can also check if the version is available to install
  if goenv install -l | grep -q "^${request}$"; then
    return 0
  fi
  return 1
}
