#!/usr/bin/env bash
#
# Installs Google Chrome browser
#

set -euo pipefail

REPO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../reposetorys/browsers/repo-chrome.sh"

echo "Installing Google Chrome..."

# Ensure repo exists
bash "$REPO_SCRIPT"

# Install chrome
$SUDO apt-get update -y
$SUDO apt-get install -y google-chrome-stable

echo "Google Chrome installation finished."
