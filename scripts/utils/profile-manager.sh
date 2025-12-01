#!/usr/bin/env bash
#
# Profile Manager
# Determines deployment mode of system-manager
#

set -euo pipefail

SYSTEM_PROFILE="default"

parse_profile_flag() {
  for arg in "$@"; do
    case "$arg" in
      --profile=*)
        SYSTEM_PROFILE="${arg#*=}"
        ;;
    esac
  done
}

get_profile() {
  echo "$SYSTEM_PROFILE"
}
