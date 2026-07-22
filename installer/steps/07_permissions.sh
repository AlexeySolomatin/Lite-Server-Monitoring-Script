#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Step 07: Permissions & Global CLI Symlink
# -----------------------------------------------------------------------------

set -Eeuo pipefail

step_permissions() {
    log_info "Setting correct permissions across LSM directories..."

    local lsm_root="${LSM_ROOT:-/opt/lsm}"

    # 1. Выставляем права на директории и файлы
    if [[ -d "${lsm_root}" ]]; then
        chmod -R 755 "${lsm_root}"
        chmod -R 755 "${lsm_root}/bin"
        chmod +x "${lsm_root}/bin/lsm" 2>/dev/null || true
    fi

    # 2. Создаем глобальную симлинку в /usr/local/bin/lsm
    log_info "Creating global CLI symlink (/usr/local/bin/lsm)..."
    
    if [[ -f "${lsm_root}/bin/lsm" ]]; then
        ln -sf "${lsm_root}/bin/lsm" "/usr/local/bin/lsm"
        log_success "Global command 'lsm' linked to /usr/local/bin/lsm"
    else
        log_warn "Executable ${lsm_root}/bin/lsm not found, skipping symlink creation."
    fi

    log_success "Lite Server Monitor installation completed successfully!"
    log_info "Run 'lsm help' to see available commands."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    LSM_ROOT="${LSM_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
    export LSM_ROOT
    if [[ -f "${LSM_ROOT}/lib/core/common.sh" ]]; then source "${LSM_ROOT}/lib/core/common.sh"; fi
    if [[ -f "${LSM_ROOT}/lib/core/ui.sh" ]]; then source "${LSM_ROOT}/lib/core/ui.sh"; fi
    step_permissions
fi
