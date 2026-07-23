#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Базовое окружение и общие системные переменные
# Путь: lib/core/common.sh
# ==============================================================================

set -Eeuo pipefail

# Автоопределение корневого каталога проекта, если он еще не передан
if [[ -z "${LSM_ROOT:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # На два уровня вверх из lib/core -> корень проекта
    LSM_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
fi

export LSM_ROOT
export PROJECT_ROOT="${LSM_ROOT}"
export PROJECT_NAME="Lite Server Monitor"

# Динамическое чтение версии из файла VERSION (без хардкода)
if [[ -f "${LSM_ROOT}/VERSION" ]]; then
    PROJECT_VERSION="$(tr -d '\r\n' < "${LSM_ROOT}/VERSION")"
else
    PROJECT_VERSION="0.1.1-alpha"
fi
export PROJECT_VERSION

# Пути к основным директориям системы
export LSM_CONFIG_DIR="${LSM_CONFIG_DIR:-/etc/lsm}"
export LSM_LOG_DIR="${LSM_LOG_DIR:-/var/log/lsm}"
export LSM_DATA_DIR="${LSM_DATA_DIR:-/var/lib/lsm}"

#
# Вспомогательные функции (Системные хелперы)
#

# Проверка прав root (возвращает true/false)
is_root() {
    [[ "${EUID:-$(id -u)}" -eq 0 ]]
}

# Строгая проверка root с аварийным выходом
check_root() {
    if ! is_root; then
        if declare -f log_error >/dev/null 2>&1; then
            log_error "Скрипт должен быть запущен с правами root (или через sudo)."
        else
            echo "Ошибка: Скрипт должен быть запущен с правами root." >&2
        fi
        exit 1
    fi
}

# Проверка наличия утилиты в $PATH
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Проверка поддерживаемого семейства ОС (Debian / Ubuntu / Mint / PopOS)
is_supported_os() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        case "${ID:-}" in
            debian|ubuntu|linuxmint|pop) return 0 ;;
            *)
                if [[ "${ID_LIKE:-}" == *"debian"* || "${ID_LIKE:-}" == *"ubuntu"* ]]; then
                    return 0
                fi
                ;;
        esac
    fi
    return 1
}

# Проверка сетевого подключения
has_internet() {
    ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1 || ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1
}

#
# Загрузка конфигурационных файлов (/etc/lsm/*.conf)
# Согласно Разделам 6 и 7 Архитектурного Контекста
#
load_lsm_configs() {
    local config_files=(
        "config.conf"
        "modules.conf"
        "notifications.conf"
        "thresholds.conf"
        "secrets.conf"
    )

    for cfg in "${config_files[@]}"; do
        local cfg_path="${LSM_CONFIG_DIR}/${cfg}"
        if [[ -f "${cfg_path}" ]]; then
            # Обеспечиваем строго ограничение прав (0600) для файла секретов
            if [[ "${cfg}" == "secrets.conf" ]]; then
                chmod 600 "${cfg_path}" 2>/dev/null || true
            fi
            # shellcheck source=/dev/null
            source "${cfg_path}"
        fi
    done
}

# Автоматическая подгрузка конфигов при их наличии
if [[ -d "${LSM_CONFIG_DIR}" ]]; then
    load_lsm_configs
fi
