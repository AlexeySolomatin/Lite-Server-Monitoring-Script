#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Step 05: Monitoring Modules Installation
# -----------------------------------------------------------------------------

set -Eeuo pipefail

step_modules() {
    log_info "Installing enabled monitoring modules..."

    local modules_dir="${LSM_ROOT:-/opt/lsm}/modules"

    # Если массив SELECTED_MODULES пуст или не объявлен, ставим дефолтный набор
    if [[ -z "${SELECTED_MODULES:-}" || ${#SELECTED_MODULES[@]} -eq 0 ]]; then
        SELECTED_MODULES=("disk" "system" "temperature" "smart" "login")
    fi

    log_info "Selected modules: ${SELECTED_MODULES[*]}"

    for module in "${SELECTED_MODULES[@]}"; do
        local installer="${modules_dir}/${module}/install.sh"

        if [[ -f "${installer}" ]]; then
            log_info "Triggering module installer: ${module}..."
            bash "${installer}"
        else
            log_warn "Installer for module '${module}' not found at ${installer}, skipping."
        fi
    done

    log_success "All selected monitoring modules installed."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    LSM_ROOT="${LSM_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
    export LSM_ROOT

    if [[ -f "${LSM_ROOT}/lib/core/common.sh" ]]; then source "${LSM_ROOT}/lib/core/common.sh"; fi
    if [[ -f "${LSM_ROOT}/lib/core/ui.sh" ]]; then source "${LSM_ROOT}/lib/core/ui.sh"; fi

    step_modules
fi
