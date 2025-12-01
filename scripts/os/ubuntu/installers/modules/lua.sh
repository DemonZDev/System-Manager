#!/usr/bin/env bash
#
# Interactive Lua installer
#

set -euo pipefail

REPO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../repositories/modules/lua.sh"

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
log_info "Select Lua version to install:"
echo

index=1
for ver in "${AVAILABLE_LUA_VERSIONS[@]}"; do
  printf "%2d) Lua %s\n" "$index" "${ver}"
  index=$((index+1))
done

echo
read -rp "Enter number [1-$((${#AVAILABLE_LUA_VERSIONS[@]}))]: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
  log_error "Invalid input. Please enter a number."
  exit 1
fi

if (( choice < 1 || choice > ${#AVAILABLE_LUA_VERSIONS[@]} )); then
  log_error "Choice out of range."
  exit 1
fi

LUA_VERSION="${AVAILABLE_LUA_VERSIONS[$((choice-1))]}"

echo
log_info "Installing Lua ${LUA_VERSION}..."
echo

if check_version_supported "$LUA_VERSION"; then
  install_lua_version "$LUA_VERSION"
else
  log_error "Version not supported."
  exit 1
fi

# Set the selected version as the default
log_info "Setting Lua ${LUA_VERSION} as default..."
$SUDO update-alternatives --install /usr/bin/lua lua "/usr/bin/lua${LUA_VERSION}" 100
$SUDO update-alternatives --install /usr/bin/luac luac "/usr/bin/luac${LUA_VERSION}" 100
$SUDO update-alternatives --set lua "/usr/bin/lua${LUA_VERSION}"
$SUDO update-alternatives --set luac "/usr/bin/luac${LUA_VERSION}"


echo
log_info "Lua ${LUA_VERSION} successfully installed and set as default."
lua -v
