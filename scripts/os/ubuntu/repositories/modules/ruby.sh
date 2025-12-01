#!/usr/bin/env bash
#
# Installs and manages Ruby versions using rvm
#

set -euo pipefail

# This is a partial list. `rvm list known` provides a complete list.
AVAILABLE_RUBY_VERSIONS=(
    "3.3.0"
    "3.2.2"
    "3.1.4"
    "3.0.6"
    "2.7.8"
)

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Function to install rvm
install_rvm() {
    log_info "Installing rvm..."
    # Install gpg keys
    gpg2 --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    # Install rvm
    curl -sSL https://get.rvm.io | bash -s stable
    # Add rvm to the path for the current session
    source "$HOME/.rvm/scripts/rvm"
}

# Function to install a specific Ruby version
install_ruby_version() {
  local version="$1"
  log_info "Installing Ruby ${version}..."
  rvm install "$version"
}

# Function to set the default Ruby version
set_default_ruby_version() {
  local version="$1"
  log_info "Setting default Ruby version to ${version}..."
  rvm use "$version" --default
}

# Function to check if a requested version is in the list of available versions
check_version_supported() {
  local request="$1"
  for version in "${AVAILABLE_RUBY_VERSIONS[@]}"; do
    if [[ "$version" == "$request" ]]; then
      return 0
    fi
  done
  # For ruby, we can also check if the version is available to install
  if rvm list known | grep -q "\[ruby-\]${request}\[p" ; then
    return 0
  fi
  return 1
}
