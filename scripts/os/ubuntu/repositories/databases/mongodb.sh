#!/usr/bin/env bash
#
# Installs multiple MongoDB versions using the official MongoDB APT repository
#

set -euo pipefail

# This is a partial list. More versions may be available from the MongoDB APT repository.
AVAILABLE_MONGODB_VERSIONS=(
    "7.0"
    "6.0"
    "5.0"
    "4.4"
)

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Function to add the MongoDB APT repository for a specific version
add_mongodb_repo() {
    local ver="$1"
    log_info "Adding MongoDB ${ver} APT repository..."
    $SUDO apt-get update -y
    $SUDO apt-get install -y gnupg curl
    curl -fsSL "https://www.mongodb.org/static/pgp/server-${ver}.asc" | $SUDO gpg --dearmor -o "/usr/share/keyrings/mongodb-server-${ver}.gpg"
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-${ver}.gpg ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/${ver} multiverse" | $SUDO tee "/etc/apt/sources.list.d/mongodb-org-${ver}.list" > /dev/null
    $SUDO apt-get update -y
}

# Function to install a specific MongoDB version
install_mongodb_version() {
  local ver="$1"
  log_info "Installing MongoDB ${ver}..."
  $SUDO apt-get install -y "mongodb-org=${ver}.*" "mongodb-org-database=${ver}.*" "mongodb-org-server=${ver}.*" "mongodb-org-mongos=${ver}.*" "mongodb-org-shell=${ver}.*" "mongodb-org-tools=${ver}.*"
}

# Function to check if a requested version is in the list of available versions
check_version_supported() {
  local request="$1"
  for ver in "${AVAILABLE_MONGODB_VERSIONS[@]}"; do
    if [[ "$ver" == "$request" ]]; then
      return 0
    fi
  done
  return 1
}
