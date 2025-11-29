#!/usr/bin/env bash
#
# Login Manager
#

set -euo pipefail

LOG_MODE="normal"

parse_flags() {
  for arg in "$@"; do
    case "$arg" in
      --debug)
        LOG_MODE="debug"
        set -x
        ;;
      --silent)
        LOG_MODE="silent"
        ;;
    esac
  done
}

timestamp() {
  date +"%Y-%m-%d %H:%M:%S"
}

log_banner() {
  [[ "$LOG_MODE" == "silent" ]] && return
  echo
  echo "===================================="
  echo "  $1"
  echo "===================================="
}

log_info() {
  [[ "$LOG_MODE" == "silent" ]] && return
  echo "[INFO] [$LOG_MODE] $1"
}

log_success() {
  [[ "$LOG_MODE" == "silent" ]] && return
  echo "[OK] [$LOG_MODE] $1"
}

log_warn() {
  [[ "$LOG_MODE" != "silent" ]] && echo "[WARN] $1"
}

log_error() {
  echo "[ERROR] $1" >&2
}

log_empty() {
  [[ "$LOG_MODE" == "silent" ]] && return
  echo ""
}
