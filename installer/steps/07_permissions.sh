#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Step 07: Permissions & Global CLI Symlink
# -----------------------------------------------------------------------------

set -Eeuo pipefail

step_permissions() {
    log_info "Setting correct permissions across LSM directories..."

    local target_dir="/opt/lsm"

    if [[ -d "${target_dir}" ]]; then
        chmod -R 755 "${target_dir}"
        chmod +x "${target_dir}/bin/lsm" 2>/dev/null || true
    fi

    log_info "Creating global CLI symlink (/usr/local/bin/lsm)..."
    
    if [[ -f "${target_dir}/bin/lsm" ]]; then
        ln -sf "${target_dir}/bin/lsm" "/usr/local/bin/lsm"
        log_success "Global command 'lsm' linked to /usr/local/bin/lsm"
    else
        log_warn "Executable ${target_dir}/bin/lsm not found, skipping symlink creation."
    fi

    log_success "Lite Server Monitor installation completed successfully!"
    log_info "Run 'lsm help' to see available commands."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    LSM_ROOT="${LSM_ROOT:-/opt/lsm}"
    export LSM_ROOT
    if [[ -f "${LSM_ROOT}/lib/core/common.sh" ]]; then source "${LSM_ROOT}/lib/core/common.sh"; fi
    if [[ -f "${LSM_ROOT}/lib/core/ui.sh" ]]; then source "${LSM_ROOT}/lib/core/ui.sh"; fi
    step_permissions
fi
