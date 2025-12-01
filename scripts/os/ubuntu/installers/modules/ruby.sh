#!/usr/bin/env bash
#
# Interactive Ruby installer
#

set -euo pipefail

REPO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../repositories/modules/ruby.sh"

# Load functions from repo script
# shellcheck source=/dev/null
. "$REPO_SCRIPT"

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Install rvm if not already installed
if ! command -v rvm >/dev/null 2>&1; then
  install_rvm
fi


echo
log_info "Select Ruby version to install and set as default:"
echo

index=1
for version in "${AVAILABLE_RUBY_VERSIONS[@]}"; do
  printf "%2d) %s\n" "$index" "$version"
  index=$((index+1))
done

echo
read -rp "Enter number [1-$((${#AVAILABLE_RUBY_VERSIONS[@]}))]: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
  log_error "Invalid input. Please enter a number."
  exit 1
fi

if (( choice < 1 || choice > ${#AVAILABLE_RUBY_VERSIONS[@]} )); then
  log_error "Choice out of range."
  exit 1
fi

SELECTED_VERSION="${AVAILABLE_RUBY_VERSIONS[$((choice-1))]}"

echo
log_info "Installing Ruby ${SELECTED_VERSION}..."
echo

if check_version_supported "$SELECTED_VERSION"; then
  install_ruby_version "$SELECTED_VERSION"
  set_default_ruby_version "$SELECTED_VERSION"
else
  log_error "Version not supported."
  exit 1
fi

echo
log_info "Ruby ${SELECTED_VERSION} successfully installed and set as default."
ruby -v
