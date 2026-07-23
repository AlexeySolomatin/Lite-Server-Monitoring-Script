#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Скрипт удаления модуля мониторинга ИБП (UPS)
# Путь: modules/ups/uninstall.sh
# ==============================================================================

set -Eeuo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LSM_ROOT="${LSM_ROOT:-/opt/lsm}"

# Подключение базовых библиотек
if [[ -f "${LSM_ROOT}/lib/core/common.sh" ]]; then
    # shellcheck source=/dev/null
    source "${LSM_ROOT}/lib/core/common.sh"
fi

if [[ -f "${LSM_ROOT}/lib/core/ui.sh" ]]; then
    # shellcheck source=/dev/null
    source "${LSM_ROOT}/lib/core/ui.sh"
fi

if [[ -f "${LSM_ROOT}/lib/installer/deploy.sh" ]]; then
    # shellcheck source=/dev/null
    source "${LSM_ROOT}/lib/installer/deploy.sh"
fi

if [[ -f "${LSM_ROOT}/lib/installer/services.sh" ]]; then
    # shellcheck source=/dev/null
    source "${LSM_ROOT}/lib/installer/services.sh"
fi

if declare -f log_info >/dev/null 2>&1; then
    log_info "UNINSTALL" "Удаление модуля мониторинга ИБП (UPS)..."
else
    echo "Удаление модуля мониторинга ИБП (UPS)..."
fi

# 1. Остановка и отключение служб systemd
if command -v systemctl >/dev/null 2>&1; then
    if declare -f services_stop_and_disable >/dev/null 2>&1; then
        services_stop_and_disable "lsm-ups.timer" || true
        services_stop_and_disable "lsm-ups.service" || true
    else
        systemctl stop lsm-ups.timer lsm-ups.service 2>/dev/null || true
        systemctl disable lsm-ups.timer lsm-ups.service 2>/dev/null || true
    fi
fi

# 2. Удаление юнитов Systemd
if declare -f deploy_remove_file >/dev/null 2>&1; then
    deploy_remove_file "/etc/systemd/system/lsm-ups.service"
    deploy_remove_file "/etc/systemd/system/lsm-ups.timer"
else
    rm -f "/etc/systemd/system/lsm-ups.service"
    rm -f "/etc/systemd/system/lsm-ups.timer"
fi

# Перезагрузка конфигурации systemd
if command -v systemctl >/dev/null 2>&1; then
    systemctl daemon-reload || true
fi

# 3. Удаление конфигурационного файла модуля
if declare -f deploy_remove_file >/dev/null 2>&1; then
    deploy_remove_file "/etc/lsm/modules/ups.conf"
else
    rm -f "/etc/lsm/modules/ups.conf"
fi

# 4. Удаление рабочей директории модуля
if declare -f deploy_remove_directory >/dev/null 2>&1; then
    deploy_remove_directory "${LSM_ROOT}/modules/ups"
else
    rm -rf "${LSM_ROOT}/modules/ups"
fi

if declare -f log_success >/dev/null 2>&1; then
    log_success "UNINSTALL" "Модуль мониторинга ИБП (UPS) успешно удалён."
else
    echo "Модуль мониторинга ИБП (UPS) успешно удалён."
fi
