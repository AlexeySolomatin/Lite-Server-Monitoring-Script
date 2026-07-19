#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Version Command
# -----------------------------------------------------------------------------

set -Eeuo pipefail

VERSION_FILE="${LSM_ROOT}/VERSION"

if [[ -f "${VERSION_FILE}" ]]; then
    cat "${VERSION_FILE}"
else
    echo "Development"
fi
