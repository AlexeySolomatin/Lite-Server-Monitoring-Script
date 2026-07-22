#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# CLI Command: Report
# -----------------------------------------------------------------------------

set -Eeuo pipefail

LSM_ROOT="${LSM_ROOT:-/opt/lsm}"

if [[ -f "${LSM_ROOT}/lib/core/common.sh" ]]; then source "${LSM_ROOT}/lib/core/common.sh"; fi
if [[ -f "${LSM_ROOT}/lib/core/ui.sh" ]]; then source "${LSM_ROOT}/lib/core/ui.sh"; fi

ui_section "LSM System Diagnostic Report"

echo -e "\n=== Memory Usage ==="
free -h 2>/dev/null || echo "Unable to fetch RAM stats"

echo -e "\n=== Filesystem Usage ==="
df -h -x tmpfs -x devtmpfs 2>/dev/null || echo "Unable to fetch disk stats"

echo -e "\n=== Top 5 CPU Consuming Processes ==="
ps aux --sort=-%cpu 2>/dev/null | head -n 6 || true

echo ""
log_success "Report generated successfully."
