#!/usr/bin/env bash
#
# Interactive Node.js installer
#

set -euo pipefail

REPO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../reposetorys/modules/repo-node-js.sh"

# Load functions from repo script
# shellcheck source=/dev/null
. "$REPO_SCRIPT"

echo
echo "Select Node.js version to install:"
echo

index=1
for ver in "${AVAILABLE_NODE_VERSIONS[@]}"; do
  echo "$index) v${ver}.x"
  index=$((index+1))
done

echo
read -rp "Enter number [1-$((${#AVAILABLE_NODE_VERSIONS[@]}))]: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
  echo "Invalid input."
  exit 1
fi

if (( choice < 1 || choice > ${#AVAILABLE_NODE_VERSIONS[@]} )); then
  echo "Choice out of range."
  exit 1
fi

NODE_VERSION="${AVAILABLE_NODE_VERSIONS[$((choice-1))]}"

echo
echo "Installing Node.js v${NODE_VERSION}.x ..."
echo

if check_version_supported "$NODE_VERSION"; then
  install_node_repo "$NODE_VERSION"
else
  echo "Version not supported."
  exit 1
fi

$SUDO apt-get install -y nodejs

echo
echo "Node.js successfully installed."
echo "node: $(node -v)"
echo "npm : $(npm -v)"
