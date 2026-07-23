#!/usr/bin/env bash
# shellcheck disable=SC2034
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Installation Mode Screen
# -----------------------------------------------------------------------------

set -Eeuo pipefail

INSTALL_MODE="preset"

screen_install_mode() {
    wizard_header

    echo -e "${CLR_BOLD}Выберите режим установки:${CLR_RESET}"
    echo
    echo -e "  ${CLR_CYAN}1)${CLR_RESET} ${CLR_BOLD}Быстрая установка (Рекомендуется)${CLR_RESET}"
    echo -e "     Установка стандартного комплекта модулей (disk, system, temperature, smart, login)."
    echo
    echo -e "  ${CLR_CYAN}2)${CLR_RESET} ${CLR_BOLD}Пользовательская установка${CLR_RESET}"
    echo -e "     Выбор конкретных модулей и тонкая настройка параметров."
    echo

    while true; do
        read -rp "$(echo -e "${CLR_BOLD}Выберите режим [1-2]${CLR_RESET} [${CLR_YELLOW}1${CLR_RESET}]: ")" answer
        answer="${answer:-1}"

        case "${answer}" in
            1)
                INSTALL_MODE="preset"
                break
                ;;
            2)
                INSTALL_MODE="custom"
                break
                ;;
            *)
                echo -e "${CLR_RED}Неверный выбор. Пожалуйста, введите 1 или 2.${CLR_RESET}"
                ;;
        esac
    done
}
