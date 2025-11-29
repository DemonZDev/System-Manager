#!/usr/bin/env bash
#
# Ubuntu Manager
# Controls install, delete, reinstall menus and category logic
#

set -euo pipefail

UBUNTU_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLERS_DIR="${UBUNTU_DIR}/installers"

#########################################
# Detection helpers
#########################################

has_desktop() {
  dpkg -l 2>/dev/null | grep -qE 'xfce4|mate-desktop|kde-plasma-desktop|cinnamon-desktop|ubuntu-desktop|gnome-shell'
}

has_browser() {
  command -v firefox >/dev/null 2>&1 \
  || command -v google-chrome >/dev/null 2>&1 \
  || command -v opera >/dev/null 2>&1
}

has_vnc() {
  dpkg -l 2>/dev/null | grep -qE 'x11vnc|tightvncserver|tigervnc-standalone-server|xrdp'
}

has_database() {
  dpkg -l 2>/dev/null | grep -qE 'mysql-server|postgresql|mongodb-org'
}

has_modules() {
  command -v node >/dev/null 2>&1 \
  || command -v python3 >/dev/null 2>&1 \
  || command -v go >/dev/null 2>&1 \
  || command -v rustc >/dev/null 2>&1 \
  || command -v php >/dev/null 2>&1 \
  || command -v ruby >/dev/null 2>&1 \
  || command -v java >/dev/null 2>&1 \
  || command -v dotnet >/dev/null 2>&1 \
  || command -v lua >/dev/null 2>&1
}

#########################################
# MAIN MENU
#########################################

ubuntu_main_menu() {
  while true; do
    log_empty
    echo "What do you want?"
    echo "1) Install"
    echo "2) Delete"
    echo "3) Reinstall"
    echo "4) Exit"
    echo

    read -rp "Select option [1-4]: " choice
    case "$choice" in
      1) ubuntu_install_menu ;;
      2) ubuntu_delete_menu ;;
      3) ubuntu_reinstall_menu ;;
      4) return ;;
      *) log_warn "Invalid choice." ;;
    esac
  done
}

#########################################
# INSTALL MENU
#########################################

ubuntu_install_menu() {
  while true; do
    log_empty
    echo "Install:"
    echo "1) Desktop"
    echo "2) VNC"
    echo "3) Databases"
    echo "4) Modules"

    local idx=5
    if has_desktop; then
      echo "${idx}) Browsers"
      HAS_BROWSERS_OPTION=1
      idx=$((idx+1))
    else
      HAS_BROWSERS_OPTION=0
    fi

    echo "${idx}) Back"
    local back_index=$idx
    echo

    read -rp "Select option [1-${back_index}]: " choice

    case "$choice" in
      1) ubuntu_install_desktop ;;
      2) ubuntu_install_vnc ;;
      3) ubuntu_install_database ;;
      4) ubuntu_install_modules ;;
      *)
        if [[ "$HAS_BROWSERS_OPTION" -eq 1 && "$choice" -eq 5 ]]; then
          ubuntu_install_browsers
        elif [[ "$choice" -eq "$back_index" ]]; then
          return
        else
          log_warn "Invalid option."
        fi
        ;;
    esac
  done
}

#########################################
# DELETE MENU (DYNAMIC)
#########################################

ubuntu_delete_menu() {
  local options=()
  local actions=()

  if has_desktop; then
    options+=("Desktop")
    actions+=("ubuntu_delete_desktop")
  fi
  if has_vnc; then
    options+=("VNC")
    actions+=("ubuntu_delete_vnc")
  fi
  if has_database; then
    options+=("Databases")
    actions+=("ubuntu_delete_database")
  fi
  if has_modules; then
    options+=("Modules")
    actions+=("ubuntu_delete_modules")
  fi
  if has_browser; then
    options+=("Browsers")
    actions+=("ubuntu_delete_browsers")
  fi

  if [[ "${#options[@]}" -eq 0 ]]; then
    log_warn "Nothing installed to delete."
    return
  fi

  while true; do
    log_empty
    echo "Delete:"
    local i
    for i in "${!options[@]}"; do
      printf "%s) %s\n" "$((i+1))" "${options[$i]}"
    done
    local back=$(( ${#options[@]} + 1 ))
    echo "${back}) Back"
    echo

    read -rp "Select option [1-${back}]: " choice

    if [[ "$choice" -eq "$back" ]]; then
      return
    elif [[ "$choice" -ge 1 && "$choice" -le "${#options[@]}" ]]; then
      local i=$((choice - 1))
      "${actions[$i]}"
    else
      log_warn "Invalid choice."
    fi
  done
}

#########################################
# REINSTALL MENU
#########################################

ubuntu_reinstall_menu() {
  local options=()
  local del=()
  local add=()

  if has_desktop; then
    options+=("Desktop")
    del+=("ubuntu_delete_desktop")
    add+=("ubuntu_install_desktop")
  fi
  if has_vnc; then
    options+=("VNC")
    del+=("ubuntu_delete_vnc")
    add+=("ubuntu_install_vnc")
  fi
  if has_database; then
    options+=("Databases")
    del+=("ubuntu_delete_database")
    add+=("ubuntu_install_database")
  fi
  if has_modules; then
    options+=("Modules")
    del+=("ubuntu_delete_modules")
    add+=("ubuntu_install_modules")
  fi
  if has_browser; then
    options+=("Browsers")
    del+=("ubuntu_delete_browsers")
    add+=("ubuntu_install_browsers")
  fi

  if [[ "${#options[@]}" -eq 0 ]]; then
    log_warn "No components to reinstall."
    return
  fi

  while true; do
    log_empty
    echo "Reinstall:"
    local i
    for i in "${!options[@]}"; do
      printf "%s) %s\n" "$((i+1))" "${options[$i]}"
    done
    local back=$(( ${#options[@]} + 1 ))
    echo "${back}) Back"
    echo

    read -rp "Select option [1-${back}]: " choice

    if [[ "$choice" -eq "$back" ]]; then
      return
    elif [[ "$choice" -ge 1 && "$choice" -le "${#options[@]}" ]]; then
      local i=$((choice - 1))
      "${del[$i]}"
      "${add[$i]}"
    else
      log_warn "Invalid choice."
    fi
  done
}

#########################################
# INSTALL HANDLERS
#########################################

ubuntu_install_desktop() {
  bash "${INSTALLERS_DIR}/desktop/xfce.sh"
}

ubuntu_install_vnc() {
  bash "${INSTALLERS_DIR}/vnc/x11vnc.sh"
}

ubuntu_install_browsers() {
  bash "${INSTALLERS_DIR}/browsers/install-firefox.sh"
  bash "${INSTALLERS_DIR}/browsers/install-chrome.sh"
}

ubuntu_install_database() {
  bash "${INSTALLERS_DIR}/databases/install-mysql.sh"
}

ubuntu_install_modules() {
  bash "${INSTALLERS_DIR}/modules/install-node-js.sh"
}

#########################################
# DELETE HANDLERS
#########################################

ubuntu_delete_desktop() {
  $SUDO apt-get purge -y xfce4 xfce4-* gnome-shell ubuntu-desktop kde-plasma-desktop cinnamon-desktop
  $SUDO apt-get autoremove -y
}

ubuntu_delete_vnc() {
  $SUDO apt-get purge -y x11vnc tigervnc-standalone-server tightvncserver xrdp
  $SUDO apt-get autoremove -y
}

ubuntu_delete_browsers() {
  $SUDO apt-get purge -y firefox google-chrome-stable opera-stable
  $SUDO apt-get autoremove -y
}

ubuntu_delete_database() {
  $SUDO apt-get purge -y mysql-server postgresql mongodb-org
  $SUDO apt-get autoremove -y
}

ubuntu_delete_modules() {
  $SUDO apt-get purge -y nodejs python3 golang rustc php ruby default-jdk dotnet-runtime lua5.4
  $SUDO apt-get autoremove -y
}
