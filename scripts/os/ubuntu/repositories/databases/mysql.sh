#!/usr/bin/env bash
#
# Installs and manages MySQL versions using Docker
#

set -euo pipefail

# This is a partial list. Any valid tag from https://hub.docker.com/_/mysql can be used.
AVAILABLE_MYSQL_VERSIONS=(
    "8.0"
    "5.7"
    "5.6"
)

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Function to install Docker
install_docker() {
    log_info "Installing Docker..."
    $SUDO apt-get update -y
    $SUDO apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null
    $SUDO apt-get update -y
    $SUDO apt-get install -y docker-ce docker-ce-cli containerd.io
}

# Function to run a specific MySQL version in a Docker container
run_mysql_container() {
  local version="$1"
  local port="$2"
  local password="$3"
  local container_name="mysql-${version}"

  log_info "Running MySQL ${version} in a Docker container named ${container_name} on port ${port}..."

  $SUDO docker run --name "${container_name}" \
    -e MYSQL_ROOT_PASSWORD="${password}" \
    -p "${port}:3306" \
    -d "mysql:${version}"
}

# Function to check if a requested version is in the list of available versions
check_version_supported() {
  local request="$1"
  for ver in "${AVAILABLE_MYSQL_VERSIONS[@]}"; do
    if [[ "$ver" == "$request" ]]; then
      return 0
    fi
  done
  return 1
}
