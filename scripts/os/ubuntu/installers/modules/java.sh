#!/usr/bin/env bash
#
# Interactive Java installer
#

set -euo pipefail

REPO_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../repositories/modules/java.sh"

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
log_info "Select Java version to install:"
echo

index=1
for ver in "${AVAILABLE_JAVA_VERSIONS[@]}"; do
  printf "%2d) OpenJDK %s\n" "$index" "${ver}"
  index=$((index+1))
done

echo
read -rp "Enter number [1-$((${#AVAILABLE_JAVA_VERSIONS[@]}))]: " choice

if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
  log_error "Invalid input. Please enter a number."
  exit 1
fi

if (( choice < 1 || choice > ${#AVAILABLE_JAVA_VERSIONS[@]} )); then
  log_error "Choice out of range."
  exit 1
fi

JAVA_VERSION="${AVAILABLE_JAVA_VERSIONS[$((choice-1))]}"

echo
log_info "Installing OpenJDK ${JAVA_VERSION}..."
echo

if check_version_supported "$JAVA_VERSION"; then
  install_java_version "$JAVA_VERSION"
else
  log_error "Version not supported."
  exit 1
fi

# Set the selected version as the default
log_info "Setting OpenJDK ${JAVA_VERSION} as default..."
$SUDO update-alternatives --set java "/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64/bin/java"
$SUDO update-alternatives --set javac "/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64/bin/javac"


echo
log_info "OpenJDK ${JAVA_VERSION} successfully installed and set as default."
java -version
javac -version
