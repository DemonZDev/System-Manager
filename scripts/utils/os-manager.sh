#!/usr/bin/env bash
#
# OS Manager
# Detect operating system and version
#

set -euo pipefail

detect_os() {
  if [[ ! -f /etc/os-release ]]; then
    log_error "/etc/os-release not found. Unable to detect OS."
    exit 1
  fi

  # shellcheck disable=SC1091
  . /etc/os-release

  OS_ID="${ID:-unknown}"
  OS_VERSION="${VERSION_ID:-unknown}"
  OS_NAME="${NAME:-unknown}"

  case "$OS_ID" in
    ubuntu|debian)
      OS_FAMILY="debian"
      ;;
    *)
      OS_FAMILY="unknown"
      ;;
  esac

  export OS_ID OS_VERSION OS_NAME OS_FAMILY
}
