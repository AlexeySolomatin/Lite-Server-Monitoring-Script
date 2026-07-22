#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Step 06: Services & Daemon Reload
# -----------------------------------------------------------------------------

set -Eeuo pipefail

step_services() {
    log_info "Reloading systemd services and timers..."

    if command -v systemctl >/dev/null 2>&1; then
        systemctl daemon-reload || true
        log_success "Systemd daemon reloaded successfully."
    else
        log_warn "Systemd is not available. Skipping daemon reload."
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    LSM_ROOT="${LSM_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
    export LSM_ROOT
    if [[ -f "${LSM_ROOT}/lib/core/common.sh" ]]; then source "${LSM_ROOT}/lib/core/common.sh"; fi
    if [[ -f "${LSM_ROOT}/lib/core/ui.sh" ]]; then source "${LSM_ROOT}/lib/core/ui.sh"; fi
    step_services
fi
