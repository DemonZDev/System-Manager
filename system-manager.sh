#!/usr/bin/env bash
#
# System Manager - Main entrypoint
# Made by DemonZ Development
#
# Responsibilities:
#   - Parse global flags (--debug, --silent, --help)
#   - Initialize logging
#   - Ensure root/sudo
#   - Detect OS & version
#   - Dispatch to OS-specific manager (Ubuntu for now)
#   - Start interactive main menu (Install / Delete / Reinstall / etc)
#

set -euo pipefail

#######################################
# Path setup
#######################################

SCRIPT_PATH="${BASH_SOURCE[0]}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
SCRIPTS_DIR="${SCRIPT_DIR}/scripts"
UTILS_DIR="${SCRIPTS_DIR}/utils"
OS_DIR="${SCRIPTS_DIR}/OS"

#######################################
# Minimal fallback echo for early errors
#######################################
_die() {
  echo "[FATAL] $*" >&2
  exit 1
}

_require_file() {
  local file="$1"
  [[ -f "$file" ]] || _die "Required file not found: $file"
}

#######################################
# Usage / help
#######################################
print_usage() {
  cat <<EOF
System Manager - Interactive system/VPS management utility

Usage:
  bash $(basename "$SCRIPT_PATH") [--debug] [--silent] [--help]

Modes:
  --debug   Enable debug mode (verbose output, shell tracing)
  --silent  Minimal output (only important status/errors)
  --help    Show this help

Behavior:
  - Detects OS and version
  - Loads OS-specific manager (Ubuntu currently supported)
  - Shows interactive menu:
      Install / Delete / Reinstall / Exit
EOF
}

#######################################
# Load core utils
#######################################

LOGGING_MANAGER="${UTILS_DIR}/logging-manager.sh"
OS_MANAGER="${UTILS_DIR}/os-manager.sh"
PROFILE_MANAGER="${UTILS_DIR}/profile-manager.sh"

_require_file "$LOGGING_MANAGER"
_require_file "$OS_MANAGER"
# profile-manager is optional for now, but we try to load it if present

# shellcheck source=/dev/null
. "$LOGGING_MANAGER"
# shellcheck source=/dev/null
. "$OS_MANAGER"
if [[ -f "$PROFILE_MANAGER" ]]; then
  # shellcheck source=/dev/null
  . "$PROFILE_MANAGER"
fi

#######################################
# Global argument parsing (flags)
#######################################

GLOBAL_ARGS=("$@")

parse_global_args() {
  local arg
  for arg in "${GLOBAL_ARGS[@]}"; do
    case "$arg" in
      --help|-h)
        print_usage
        exit 0
        ;;
      --debug|--silent)
        # already handled by logging-manager's parse_flags
        ;;
      *)
        # Placeholder for future global flags (e.g., --non-interactive)
        ;;
    esac
  done
}

# First: pass args to logging-manager to set LOG_MODE (normal/debug/silent)
parse_flags "${GLOBAL_ARGS[@]}"

# Then handle help and any other global arguments
parse_global_args

#######################################
# Root / sudo requirements
#######################################
require_root_or_sudo() {
  if [[ "$EUID" -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
      export SUDO="sudo"
    else
      log_error "This script must be run as root or with sudo installed."
      exit 1
    fi
  else
    export SUDO=""
  fi
}

#######################################
# Trap for clean exit
#######################################
cleanup_on_exit() {
  local code=$?
  if [[ $code -ne 0 ]]; then
    log_error "System Manager exited with status $code."
  fi
  exit $code
}

trap cleanup_on_exit EXIT
trap 'log_error "Interrupted by user (Ctrl+C)."; exit 130' INT

#######################################
# Main orchestration
#######################################
main() {
  require_root_or_sudo

  # Banner
  log_banner "System Manager"
  log_info "Made by DemonZ Development"
  log_empty

  # OS detection
  detect_os

  # os-manager.sh must set:
  #   OS_ID      (e.g., ubuntu)
  #   OS_VERSION (e.g., 22.04)
  #   OS_FAMILY  (e.g., debian)
  log_info "Detected OS: ${OS_ID:-unknown} ${OS_VERSION:-unknown}"
  log_info "OS family : ${OS_FAMILY:-unknown}"
  log_empty

  case "${OS_ID:-unknown}" in
    ubuntu)
      local ubuntu_manager="${OS_DIR}/ubuntu/ubuntu-manager.sh"
      _require_file "$ubuntu_manager"
      # shellcheck source=/dev/null
      . "$ubuntu_manager"

      # ubuntu-manager.sh must define: ubuntu_main_menu
      if ! declare -f ubuntu_main_menu >/dev/null 2>&1; then
        log_error "ubuntu_main_menu function not found in ubuntu-manager.sh"
        exit 1
      fi

      # Hand off control to Ubuntu-specific menu:
      ubuntu_main_menu
      ;;

    *)
      log_error "OS '${OS_ID:-unknown}' is not supported yet."
      log_info "Currently supported: Ubuntu."
      exit 1
      ;;
  esac

  log_empty
  log_success "System Manager session finished."
}

main
