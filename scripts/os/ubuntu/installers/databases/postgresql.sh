#!/usr/bin/env bash
#
# Interactive PostgreSQL installer
#

set -euo pipefail

REPO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../repositories/databases/postgresql.sh"

# Load functions from repo script
# shellcheck source=/dev/null
. "$REPO_SCRIPT"

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

add_postgresql_repo

echo
log_info "Select PostgreSQL version to install:"
echo

index=1
for ver in "${AVAILABLE_POSTGRESQL_VERSIONS[@]}"; do
  printf "%2d) PostgreSQL %s\n" "$index" "${ver}"
  index=$((index+1))
done

echo
read -rp "Enter number [1-$((${#AVAILABLE_POSTGRESQL_VERSIONS[@]}))]: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
  log_error "Invalid input. Please enter a number."
  exit 1
fi

if (( choice < 1 || choice > ${#AVAILABLE_POSTGRESQL_VERSIONS[@]} )); then
  log_error "Choice out of range."
  exit 1
fi

POSTGRESQL_VERSION="${AVAILABLE_POSTGRESQL_VERSIONS[$((choice-1))]}"

echo
log_info "Installing PostgreSQL ${POSTGRESQL_VERSION}..."
echo

if check_version_supported "$POSTGRESQL_VERSION"; then
  install_postgresql_version "$POSTGRESQL_VERSION"
else
  log_error "Version not supported."
  exit 1
fi

echo
log_info "PostgreSQL ${POSTGRESQL_VERSION} successfully installed."
log_info "You can check the status of your PostgreSQL clusters with the command:"
log_info "pg_lsclusters"
