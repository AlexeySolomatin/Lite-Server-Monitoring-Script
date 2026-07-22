#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# CLI Command: Status
# -----------------------------------------------------------------------------

set -Eeuo pipefail

LSM_ROOT="${LSM_ROOT:-/opt/lsm}"

if [[ -f "${LSM_ROOT}/lib/core/common.sh" ]]; then source "${LSM_ROOT}/lib/core/common.sh"; fi
if [[ -f "${LSM_ROOT}/lib/core/ui.sh" ]]; then source "${LSM_ROOT}/lib/core/ui.sh"; fi

ui_section "LSM Monitor Status"

echo -e "System Info: $(uname -snrm)"
echo -e "Uptime:      $(uptime -p 2>/dev/null || uptime)"
echo "--------------------------------------------------"

if command -v systemctl >/dev/null 2>&1; then
    echo -e "Active Monitoring Timers:"
    systemctl list-timers "lsm-*" --no-pager || echo "No active LSM timers found."
else
    log_warn "Systemd is not available on this system."
fi
