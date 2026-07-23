#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Библиотека управления правами доступа и владельцами файлов
# Путь: lib/installer/permissions.sh
# ==============================================================================

set -Eeuo pipefail

# Защита от повторного подключения файла
[[ -n "${LSM_PERMISSIONS_LOADED:-}" ]] && return 0
readonly LSM_PERMISSIONS_LOADED=1

# Переменные основных директорий
LSM_ETC_DIR="${LSM_ETC_DIR:-/etc/lsm}"
LSM_LOG_DIR="${LSM_LOG_DIR:-/var/log/lsm}"
LSM_DATA_DIR="${LSM_DATA_DIR:-/var/lib/lsm}"

#
# Установка владельца и прав доступа на отдельный объект
#
permissions_set() {
    local path="${1:-}"
    local mode="${2:-}"
    local owner="${3:-root}"
    local group="${4:-root}"

    if [[ -z "${path}" || -z "${mode}" ]]; then
        return 1
    fi

    [[ -e "${path}" ]] || return 1

    chmod "${mode}" "${path}"
    chown "${owner}:${group}" "${path}"
}

#
# Корректировка прав для директории конфигураций
#
permissions_config() {
    local target_dir="${LSM_ETC_DIR}"

    if [[ -d "${target_dir}" ]]; then
        permissions_set "${target_dir}" 750 root root || true
        find "${target_dir}" -type d -exec chmod 750 {} \; 2>/dev/null || true
        find "${target_dir}" -type f -exec chmod 640 {} \; 2>/dev/null || true
    fi
}

#
# Корректировка прав для директории журналов (логов)
#
permissions_logs() {
    local target_dir="${LSM_LOG_DIR}"

    if [[ -d "${target_dir}" ]]; then
        permissions_set "${target_dir}" 750 root root || true
        find "${target_dir}" -type d -exec chmod 750 {} \; 2>/dev/null || true
        find "${target_dir}" -type f -exec chmod 640 {} \; 2>/dev/null || true
    fi
}

#
# Корректировка прав для рабочей директории состояния и данных
#
permissions_runtime() {
    local target_dir="${LSM_DATA_DIR}"

    if [[ -d "${target_dir}" ]]; then
        permissions_set "${target_dir}" 750 root root || true
        find "${target_dir}" -type d -exec chmod 750 {} \; 2>/dev/null || true
        find "${target_dir}" -type f -exec chmod 640 {} \; 2>/dev/null || true
    fi
}

#
# Комплексное применение прав ко всем системным директориям LSM
#
permissions_fix_all() {
    if declare -f log_info >/dev/null 2>&1; then
        log_info "PERMISSIONS" "Применение корректных прав доступа к директориям LSM..."
    else
        echo "[INFO] Применение прав доступа..."
    fi

    permissions_config
    permissions_logs
    permissions_runtime
}
