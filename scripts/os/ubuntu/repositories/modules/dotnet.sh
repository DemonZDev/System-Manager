#!/usr/bin/env bash
#
# Adds the Microsoft package repository for multiple .NET versions
#

set -euo pipefail

# This is a partial list and may not be 100% accurate.
# It is based on general knowledge of .NET versions.
AVAILABLE_DOTNET_VERSIONS=(
    "8.0"
    "7.0"
    "6.0"
    "5.0"
    "3.1"
)

log_info() {
    echo "[INFO] $*"
}

log_error() {
    echo "[ERROR] $*" >&2
}

# Function to add the Microsoft package repository
add_microsoft_repo() {
    log_info "Adding Microsoft package repository..."
    # Get Ubuntu version
    declare -A UBUNTU_CODENAMES
    UBUNTU_CODENAMES[22.04]="jammy"
    UBUNTU_CODENAMES[20.04]="focal"
    UBUNTU_CODENAMES[18.04]="bionic"
    OS_VERSION=$(lsb_release -rs)
    CODE_NAME=${UBUNTU_CODENAMES[$OS_VERSION]}

    if [ -z "$CODE_NAME" ]; then
        log_error "Unsupported Ubuntu version: $OS_VERSION"
        exit 1
    fi

    # Add the Microsoft package signing key to your list of trusted keys and add the package repository
    wget "https://packages.microsoft.com/config/ubuntu/${OS_VERSION}/packages-microsoft-prod.deb" -O packages-microsoft-prod.deb
    $SUDO dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    $SUDO apt-get update -y
}

# Function to install a specific .NET SDK version
install_dotnet_version() {
  local ver="$1"
  log_info "Installing .NET SDK ${ver}..."
  $SUDO apt-get install -y "dotnet-sdk-${ver}"
}

# Function to check if a requested version is in the list of available versions
check_version_supported() {
  local request="$1"
  for ver in "${AVAILABLE_DOTNET_VERSIONS[@]}"; do
    if [[ "$ver" == "$request" ]]; then
      return 0
    fi
  done
  return 1
}
