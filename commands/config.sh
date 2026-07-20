#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Configuration Command
# -----------------------------------------------------------------------------

set -Eeuo pipefail

CONFIG_DIR="/etc/lsm"

echo
echo "Configuration files"
echo "==================="
echo

find "${CONFIG_DIR}" -type f | sort
