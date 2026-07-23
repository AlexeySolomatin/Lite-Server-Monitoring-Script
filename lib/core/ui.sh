#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Библиотека пользовательского интерфейса и форматирования терминала
# Путь: lib/core/ui.sh
# ==============================================================================

set -Eeuo pipefail

# Защита от повторного подключения файла
[[ -n "${LSM_UI_LOADED:-}" ]] && return 0
readonly LSM_UI_LOADED=1

# Автоопределение версии из файла VERSION (если PROJECT_VERSION еще не задана)
if [[ -z "${PROJECT_VERSION:-}" ]]; then
    LSM_ROOT="${LSM_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
    if [[ -f "${LSM_ROOT}/VERSION" ]]; then
        PROJECT_VERSION="$(tr -d '\r\n' < "${LSM_ROOT}/VERSION")"
    else
        PROJECT_VERSION="0.1.1-alpha"
    fi
    export PROJECT_VERSION
fi

# Определение цветов (ANSI-C quoting гарантирует работу с 'cat' и 'echo')
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    COLOR_RESET=$'\033[0m'
    COLOR_BOLD=$'\033[1m'
    COLOR_RED=$'\033[0;31m'
    COLOR_GREEN=$'\033[0;32m'
    COLOR_YELLOW=$'\033[0;33m'
    COLOR_BLUE=$'\033[0;34m'
    COLOR_CYAN=$'\033[0;36m'
else
    COLOR_RESET=""
    COLOR_BOLD=""
    COLOR_RED=""
    COLOR_GREEN=""
    COLOR_YELLOW=""
    COLOR_BLUE=""
    COLOR_CYAN=""
fi

# Вывод баннера проекта
print_header() {
    cat << EOF

${COLOR_CYAN}${COLOR_BOLD}=====================================================================${COLOR_RESET}
${COLOR_CYAN}${COLOR_BOLD}   __    ____  __  __   (LSM) Lite Server Monitor                    ${COLOR_RESET}
${COLOR_CYAN}${COLOR_BOLD}  / /   / __/ /  \/  |   Lightweight System Monitoring & Alerting     ${COLOR_RESET}
${COLOR_CYAN}${COLOR_BOLD} / /___ \__ \ / /\_/ |   Version: ${PROJECT_VERSION}                           ${COLOR_RESET}
${COLOR_CYAN}${COLOR_BOLD}/_____//____//_/   /_/   Linux Server Management Tools                ${COLOR_RESET}
${COLOR_CYAN}${COLOR_BOLD}=====================================================================${COLOR_RESET}

EOF
}

# Алиас для вывода баннера
ui_banner() {
    print_header
}

# Визуальное разделение блоков
ui_section() {
    local title="${1:-}"
    echo -e "\n${COLOR_BOLD}---> ${title}${COLOR_RESET}"
}

# Алиас для совместимости со шагами инсталлятора
print_section() {
    ui_section "$@"
}

# Форматирование сообщений с иконками и цветовым статусом
log_info() {
    echo -e "[${COLOR_BLUE}INFO${COLOR_RESET}] $*"
}

log_success() {
    echo -e "[${COLOR_GREEN} OK ${COLOR_RESET}] $*"
}

log_warn() {
    echo -e "[${COLOR_YELLOW}WARN${COLOR_RESET}] $*" >&2
}

log_error() {
    echo -e "[${COLOR_RED}FAIL${COLOR_RESET}] $*" >&2
}

log_debug() {
    if [[ "${LSM_DEBUG:-0}" == "1" ]]; then
        echo -e "[${COLOR_CYAN}DEBUG${COLOR_RESET}] $*"
    fi
}
