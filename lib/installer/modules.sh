#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Библиотека управления модулями
# Путь: lib/installer/modules.sh
# ==============================================================================

set -Eeuo pipefail

# Защита от повторного подключения файла
[[ -n "${LSM_MODULES_LOADED:-}" ]] && return 0
readonly LSM_MODULES_LOADED=1

# Инициализация базовых путей
LSM_ROOT="${LSM_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
LSM_MODULES_DIR="${LSM_MODULES_DIR:-${LSM_ROOT}/modules}"

#
# Проверка существования модуля
#
modules_exists() {
    local module="${1:-}"

    [[ -n "${module}" && -d "${LSM_MODULES_DIR}/${module}" ]]
}

#
# Получение списка всех доступных модулей
#
modules_list() {
    if [[ ! -d "${LSM_MODULES_DIR}" ]]; then
        return 0
    fi

    # Защита конвейера pipefail при вызове find | sort
    { find "${LSM_MODULES_DIR}" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null || true; } | sort
}

#
# Установка модуля
#
modules_install() {
    local module="${1:-}"

    if [[ -z "${module}" ]]; then
        if declare -f log_error >/dev/null 2>&1; then
            log_error "MODULES" "Имя модуля не указано."
        else
            echo "Ошибка: Имя модуля не указано." >&2
        fi
        return 1
    fi

    if ! modules_exists "${module}"; then
        if declare -f log_error >/dev/null 2>&1; then
            log_error "MODULES" "Неизвестный или отсутствующий модуль: ${module}"
        else
            echo "Ошибка: Неизвестный или отсутствующий модуль: ${module}" >&2
        fi
        return 1
    fi

    if declare -f log_info >/dev/null 2>&1; then
        log_info "MODULES" "Установка модуля: ${module}"
    fi

    local module_dir="${LSM_MODULES_DIR}/${module}"

    if [[ -f "${module_dir}/manifest.conf" ]]; then
        # shellcheck source=/dev/null
        source "${module_dir}/manifest.conf"
    fi

    if [[ -x "${module_dir}/install.sh" ]]; then
        "${module_dir}/install.sh"
    fi
}

#
# Удаление модуля
#
modules_remove() {
    local module="${1:-}"

    if [[ -z "${module}" ]]; then
        return 1
    fi

    local module_dir="${LSM_MODULES_DIR}/${module}"

    if [[ -x "${module_dir}/uninstall.sh" ]]; then
        if declare -f log_info >/dev/null 2>&1; then
            log_info "MODULES" "Удаление модуля: ${module}"
        fi
        "${module_dir}/uninstall.sh"
    fi
}

#
# Включение модуля
#
modules_enable() {
    local module="${1:-}"

    if [[ -z "${module}" ]]; then
        return 1
    fi

    local module_dir="${LSM_MODULES_DIR}/${module}"

    if [[ -x "${module_dir}/enable.sh" ]]; then
        if declare -f log_info >/dev/null 2>&1; then
            log_info "MODULES" "Включение модуля: ${module}"
        fi
        "${module_dir}/enable.sh"
    fi
}

#
# Отключение модуля
#
modules_disable() {
    local module="${1:-}"

    if [[ -z "${module}" ]]; then
        return 1
    fi

    local module_dir="${LSM_MODULES_DIR}/${module}"

    if [[ -x "${module_dir}/disable.sh" ]]; then
        if declare -f log_info >/dev/null 2>&1; then
            log_info "MODULES" "Отключение модуля: ${module}"
        fi
        "${module_dir}/disable.sh"
    fi
}
