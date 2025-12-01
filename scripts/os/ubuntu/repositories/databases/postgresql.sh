#!/usr/bin/env bash
#
# Installs multiple PostgreSQL versions using the official PostgreSQL APT repository
#

set -euo pipefail

# This is a partial list. More versions may be available from the PostgreSQL APT repository.
AVAILABLE_POSTGRESQL_VERSIONS=(
    "16"
    "15"
    "14"
    "13"
    "12"
)

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Function to add the PostgreSQL APT repository
add_postgresql_repo() {
    log_info "Adding PostgreSQL APT repository..."
    $SUDO apt-get update -y
    $SUDO apt-get install -y curl gnupg2
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | $SUDO gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
    echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | $SUDO tee /etc/apt/sources.list.d/pgdg.list > /dev/null
    $SUDO apt-get update -y
}

# Function to install a specific PostgreSQL version
install_postgresql_version() {
  local ver="$1"
  log_info "Installing PostgreSQL ${ver}..."
  $SUDO apt-get install -y "postgresql-${ver}" "postgresql-contrib-${ver}"
}

# Function to check if a requested version is in the list of available versions
check_version_supported() {
  local request="$1"
  for ver in "${AVAILABLE_POSTGRESQL_VERSIONS[@]}"; do
    if [[ "$ver" == "$request" ]]; then
      return 0
    fi
  done
  return 1
}
