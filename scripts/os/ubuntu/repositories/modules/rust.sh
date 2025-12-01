#!/usr/bin/env bash
#
# Installs and manages Rust versions using rustup
#

set -euo pipefail

AVAILABLE_RUST_TOOLCHAINS=(
    "stable"
    "beta"
    "nightly"
)

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Function to install rustup
install_rustup() {
    log_info "Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # Add rustup to the path for the current session
    source "$HOME/.cargo/env"
}

# Function to install a specific Rust toolchain
install_rust_toolchain() {
  local toolchain="$1"
  log_info "Installing Rust ${toolchain} toolchain..."
  rustup install "$toolchain"
}

# Function to set the default Rust toolchain
set_default_rust_toolchain() {
  local toolchain="$1"
  log_info "Setting default Rust toolchain to ${toolchain}..."
  rustup default "$toolchain"
}

# Function to check if a requested toolchain is in the list of available toolchains
check_toolchain_supported() {
  local request="$1"
  for toolchain in "${AVAILABLE_RUST_TOOLCHAINS[@]}"; do
    if [[ "$toolchain" == "$request" ]]; then
      return 0
    fi
  done
  return 1
}
