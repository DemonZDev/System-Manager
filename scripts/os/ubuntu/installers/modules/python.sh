#!/usr/bin/env bash
#
# Interactive Python installer
#

set -euo pipefail

REPO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../repositories/modules/python.sh"

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
log_info "Select Python version to install:"
echo

index=1
for ver_info in "${AVAILABLE_PYTHON_VERSIONS[@]}"; do
  ver="${ver_info%,*}"
  status="${ver_info#*,}"
  printf "%2d) Python %-5s (%s)\n" "$index" "${ver}" "$status"
  index=$((index+1))
done

echo
read -rp "Enter number [1-$((${#AVAILABLE_PYTHON_VERSIONS[@]}))]: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
  log_error "Invalid input. Please enter a number."
  exit 1
fi

if (( choice < 1 || choice > ${#AVAILABLE_PYTHON_VERSIONS[@]} )); then
  log_error "Choice out of range."
  exit 1
fi

SELECTED_VERSION_INFO="${AVAILABLE_PYTHON_VERSIONS[$((choice-1))]}"
PYTHON_VERSION="${SELECTED_VERSION_INFO%,*}"

echo
log_info "Installing Python ${PYTHON_VERSION}..."
echo

add_deadsnakes_ppa

if check_version_supported "$PYTHON_VERSION"; then
  install_python_version "$PYTHON_VERSION"
else
  log_error "Version not supported."
  exit 1
fi

echo
log_info "Python ${PYTHON_VERSION} successfully installed."
"python${PYTHON_VERSION}" --version
