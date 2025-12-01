#!/usr/bin/env bash
#
# Interactive PHP installer
#

set -euo pipefail

REPO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../repositories/modules/php.sh"

# Load functions from repo script
# shellcheck source=/dev/null
. "$REPO_SCRIPT"

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

echo
log_info "Select PHP version to install:"
echo

index=1
for ver in "${AVAILABLE_PHP_VERSIONS[@]}"; do
  printf "%2d) PHP %s\n" "$index" "${ver}"
  index=$((index+1))
done

echo
read -rp "Enter number [1-$((${#AVAILABLE_PHP_VERSIONS[@]}))]: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
  log_error "Invalid input. Please enter a number."
  exit 1
fi

if (( choice < 1 || choice > ${#AVAILABLE_PHP_VERSIONS[@]} )); then
  log_error "Choice out of range."
  exit 1
fi

PHP_VERSION="${AVAILABLE_PHP_VERSIONS[$((choice-1))]}"

echo
log_info "Installing PHP ${PHP_VERSION}..."
echo

add_php_ppa

if check_version_supported "$PHP_VERSION"; then
  install_php_version "$PHP_VERSION"
else
  log_error "Version not supported."
  exit 1
fi

# Set the selected version as the default
log_info "Setting PHP ${PHP_VERSION} as default..."
$SUDO update-alternatives --set php "/usr/bin/php${PHP_VERSION}"

echo
log_info "PHP ${PHP_VERSION} successfully installed and set as default."
php -v
