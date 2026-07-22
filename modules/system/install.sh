#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# System Resources Module Installer
# -----------------------------------------------------------------------------

set -Eeuo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LSM_ROOT="${LSM_ROOT:-/opt/lsm}"

if [[ -f "${LSM_ROOT}/lib/core/common.sh" ]]; then source "${LSM_ROOT}/lib/core/common.sh"; fi
if [[ -f "${LSM_ROOT}/lib/core/ui.sh" ]]; then source "${LSM_ROOT}/lib/core/ui.sh"; fi
if [[ -f "${LSM_ROOT}/lib/installer/deploy.sh" ]]; then source "${LSM_ROOT}/lib/installer/deploy.sh"; fi

log_info "Installing System Resources monitoring module..."

# 1. Директории
deploy_create_directory "${LSM_ROOT}/modules/system" "755" "root" "root"
deploy_create_directory "/etc/lsm/modules" "755" "root" "root"

# 2. Исполняемый файл
if [[ -f "${MODULE_DIR}/files/check_system.sh" ]]; then
    deploy_install_file \
        "${MODULE_DIR}/files/check_system.sh" \
        "${LSM_ROOT}/modules/system/check_system.sh" \
        "755" "root" "root"
fi

# 3. Systemd юниты
if [[ -f "${MODULE_DIR}/files/lsm-system.service" ]]; then
    deploy_install_file "${MODULE_DIR}/files/lsm-system.service" "/etc/systemd/system/lsm-system.service" "644" "root" "root"
fi
if [[ -f "${MODULE_DIR}/files/lsm-system.timer" ]]; then
    deploy_install_file "${MODULE_DIR}/files/lsm-system.timer" "/etc/systemd/system/lsm-system.timer" "644" "root" "root"
fi

# 4. Конфигурация
if [[ -f "${MODULE_DIR}/templates/system.conf" ]]; then
    if [[ ! -f "/etc/lsm/modules/system.conf" ]]; then
        deploy_install_file "${MODULE_DIR}/templates/system.conf" "/etc/lsm/modules/system.conf" "640" "root" "root"
    else
        log_warn "Configuration /etc/lsm/modules/system.conf already exists, skipping overwrite."
    fi
fi

# 5. Активация таймера
if command -v systemctl >/dev/null 2>&1; then
    systemctl daemon-reload || true
    systemctl enable --now lsm-system.timer || true
fi

log_success "System monitoring module installed successfully."
