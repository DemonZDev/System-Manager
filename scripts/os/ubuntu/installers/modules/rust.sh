#!/usr/bin/env bash
#
# Interactive Rust installer
#

set -euo pipefail

REPO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../repositories/modules/rust.sh"

# Load functions from repo script
# shellcheck source=/dev/null
. "$REPO_SCRIPT"

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Install rustup if not already installed
if ! command -v rustup >/dev/null 2>&1;
  then
  install_rustup
fi


echo
log_info "Select Rust toolchain to install and set as default:"
echo

index=1
for toolchain in "${AVAILABLE_RUST_TOOLCHAINS[@]}"; do
  printf "%2d) %s\n" "$index" "$toolchain"
  index=$((index+1))
done

echo
read -rp "Enter number [1-$((${#AVAILABLE_RUST_TOOLCHAINS[@]}))]: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
  log_error "Invalid input. Please enter a number."
  exit 1
fi

if (( choice < 1 || choice > ${#AVAILABLE_RUST_TOOLCHAINS[@]} )); then
  log_error "Choice out of range."
  exit 1
fi

SELECTED_TOOLCHAIN="${AVAILABLE_RUST_TOOLCHAINS[$((choice-1))]}"

echo
log_info "Installing Rust ${SELECTED_TOOLCHAIN} toolchain..."
echo

if check_toolchain_supported "$SELECTED_TOOLCHAIN"; then
  install_rust_toolchain "$SELECTED_TOOLCHAIN"
  set_default_rust_toolchain "$SELECTED_TOOLCHAIN"
else
  log_error "Toolchain not supported."
  exit 1
fi

echo
log_info "Rust ${SELECTED_TOOLCHAIN} toolchain successfully installed and set as default."
rustc --version
