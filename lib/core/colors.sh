#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Определение ANSI-цветов для консольного вывода
# Путь: lib/core/colors.sh
# ==============================================================================

# shellcheck disable=SC2034

# Защита от повторного подключения файла
[[ -n "${LSM_COLORS_LOADED:-}" ]] && return 0
readonly LSM_COLORS_LOADED=1

# Цвета отключаются, если:
# - Вывод (stdout) направлен не в интерактивный терминал (например, в файл или перенаправлен)
# - В системе установлена переменная окружения NO_COLOR
if [[ ! -t 1 || -n "${NO_COLOR:-}" ]]; then
    readonly COLOR_RESET=""
    readonly COLOR_BOLD=""
    readonly COLOR_RED=""
    readonly COLOR_GREEN=""
    readonly COLOR_YELLOW=""
    readonly COLOR_BLUE=""
    readonly COLOR_MAGENTA=""
    readonly COLOR_CYAN=""
    readonly COLOR_WHITE=""
else
    readonly COLOR_RESET="\033[0m"
    readonly COLOR_BOLD="\033[1m"

    readonly COLOR_RED="\033[31m"
    readonly COLOR_GREEN="\033[32m"
    readonly COLOR_YELLOW="\033[33m"
    readonly COLOR_BLUE="\033[34m"
    readonly COLOR_MAGENTA="\033[35m"
    readonly COLOR_CYAN="\033[36m"
    readonly COLOR_WHITE="\033[37m"
fi
