#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Core Common Variables & Base Environment
# -----------------------------------------------------------------------------

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
# Вспомогательные функции (System Helpers)
#

# Проверка прав root (возвращает true/false)
is_root() {
    [[ "${EUID:-$(id -u)}" -eq 0 ]]
}

# Строгая проверка root с аварийным выходом
check_root() {
    if ! is_root; then
        if declare -f log_error >/dev/null 2>&1; then
            log_error "This script must be run as root (or with sudo)."
        else
            echo "Error: This script must be run as root." >&2
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
