#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Version Command
# -----------------------------------------------------------------------------

set -Eeuo pipefail

LSM_ROOT="${LSM_ROOT:-/opt/lsm}"
VERSION_FILE="${LSM_ROOT}/VERSION"

if [[ -f "${VERSION_FILE}" ]]; then
    tr -d '\r\n' < "${VERSION_FILE}"
    echo
else
    echo "Development"
fi
