#!/usr/bin/env bash
#
# Adds the official Google Chrome APT repository and key
#

set -euo pipefail

echo "Adding Google Chrome APT repository..."

$SUDO apt-get update -y
$SUDO apt-get install -y wget gnupg ca-certificates

# Add Google signing key
wget -qO - https://dl.google.com/linux/linux_signing_key.pub \
  | $SUDO gpg --dearmor -o /usr/share/keyrings/google-linux-signing-keyring.gpg

# Add repo if not exists
if [[ ! -f /etc/apt/sources.list.d/google-chrome.list ]]; then
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-signing-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
    | $SUDO tee /etc/apt/sources.list.d/google-chrome.list >/dev/null
fi

echo "Google Chrome repository added successfully."
