#!/usr/bin/env bash
#
# Interactive MySQL installer using Docker
#

set -euo pipefail

REPO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../repositories/databases/mysql.sh"

# Load functions from repo script
# shellcheck source=/dev/null
. "$REPO_SCRIPT"

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Install Docker if not already installed
if ! command -v docker >/dev/null 2>&1; then
  install_docker
fi

echo
log_info "Select MySQL version to run in a Docker container:"
echo

index=1
for ver in "${AVAILABLE_MYSQL_VERSIONS[@]}"; do
  printf "%2d) MySQL %s\n" "$index" "${ver}"
  index=$((index+1))
done

echo
read -rp "Enter number [1-$((${#AVAILABLE_MYSQL_VERSIONS[@]}))]: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
  log_error "Invalid input. Please enter a number."
  exit 1
fi

if (( choice < 1 || choice > ${#AVAILABLE_MYSQL_VERSIONS[@]} )); then
  log_error "Choice out of range."
  exit 1
fi

MYSQL_VERSION="${AVAILABLE_MYSQL_VERSIONS[$((choice-1))]}"

echo
read -rp "Enter the host port to map to the container's port 3306 (e.g., 3306): " HOST_PORT
read -sp "Enter the MySQL root password: " MYSQL_PASSWORD
echo

if check_version_supported "$MYSQL_VERSION"; then
  run_mysql_container "$MYSQL_VERSION" "$HOST_PORT" "$MYSQL_PASSWORD"
else
  log_error "Version not supported."
  exit 1
fi

echo
log_info "MySQL ${MYSQL_VERSION} container is running."
log_info "You can connect to it using the following command:"
log_info "mysql -h 127.0.0.1 -P ${HOST_PORT} -u root -p"
