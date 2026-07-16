#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Bootstrap Installer
# -----------------------------------------------------------------------------

set -Eeuo pipefail

readonly REPOSITORY_URL="https://github.com/AlexeySolomatin/Lite-Server-Monitor.git"

readonly TEMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "${TEMP_DIR}"
}

trap cleanup EXIT

echo
echo "Lite Server Monitor Bootstrap"
echo

#
# Root
#

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Please run as root."
    exit 1
fi

#
# Git
#

if ! command -v git >/dev/null 2>&1; then
    echo "Installing git..."

    apt-get update
    apt-get install -y git
fi

echo
echo "Downloading Lite Server Monitor..."
echo

git clone "${REPOSITORY_URL}" "${TEMP_DIR}"

echo
echo "Starting installer..."
echo

exec "${TEMP_DIR}/installer/install.sh"
