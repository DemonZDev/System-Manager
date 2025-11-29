# VPS Manager

VPS Manager is a modular, OS-aware automation framework for controlling and provisioning VPS environments. It provides tools to install, delete, and reinstall system components with automatic detection of installed packages, version-aware logic, and multiple runtime output modes.

---

## Features

### Core System
- Fully Bash-based logic
- Works with root or sudo
- Smart OS & version detection
- Modular directory structure
- Safe and predictable operations
- Extensible and future-proof architecture

---

## Run Modes

| Command                     | Behavior |
|----------------------------|----------|
| `bash vps-manager.sh`      | Normal execution mode |
| `bash vps-manager.sh --debug` | Full verbose debugging with command traces |
| `bash vps-manager.sh --silent` | Only outputs success, warning, and error events |

---

## Menu System

After launch, VPS Manager presents the main menu:
