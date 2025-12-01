#!/usr/bin/env bash
#
# Interactive .NET installer
#

set -euo pipefail

REPO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../repositories/modules/dotnet.sh"

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
log_info "Select .NET SDK version to install:"
echo

index=1
for ver in "${AVAILABLE_DOTNET_VERSIONS[@]}"; do
  printf "%2d) .NET SDK %s\n" "$index" "${ver}"
  index=$((index+1))
done

echo
read -rp "Enter number [1-$((${#AVAILABLE_DOTNET_VERSIONS[@]}))]: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
  log_error "Invalid input. Please enter a number."
  exit 1
fi

if (( choice < 1 || choice > ${#AVAILABLE_DOTNET_VERSIONS[@]} )); then
  log_error "Choice out of range."
  exit 1
fi

DOTNET_VERSION="${AVAILABLE_DOTNET_VERSIONS[$((choice-1))]}"

echo
log_info "Installing .NET SDK ${DOTNET_VERSION}..."
echo

add_microsoft_repo

if check_version_supported "$DOTNET_VERSION"; then
  install_dotnet_version "$DOTNET_VERSION"
else
  log_error "Version not supported."
  exit 1
fi

echo
log_info ".NET SDK ${DOTNET_VERSION} successfully installed."
dotnet --version
