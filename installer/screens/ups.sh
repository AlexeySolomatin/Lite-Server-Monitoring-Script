#!/usr/bin/env bash
# shellcheck disable=SC2034
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# UPS Configuration Screen
# -----------------------------------------------------------------------------

set -Eeuo pipefail

INSTALL_UPS=false
UPS_PROFILE=""

screen_ups() {
    wizard_header

    echo -e "${CLR_BOLD}Настройка мониторинга ИБП (APC UPS):${CLR_RESET}"
    echo "Позволяет отслеживать уровень заряда, напряжение и статус питания от батареи."
    echo

    if ! wizard_yes_no "Включить модуль мониторинга ИБП (APC UPS)?" "n"; then
        INSTALL_UPS=false
        UPS_PROFILE=""
        return 0
    fi

    INSTALL_UPS=true

    echo
    echo -e "  ${CLR_CYAN}1)${CLR_RESET} APC Стандартный профиль (apcupsd / localhost:3551)"
    echo -e "  ${CLR_CYAN}2)${CLR_RESET} Настроить параметры позже"
    echo

    while true; do
        read -rp "$(echo -e "${CLR_BOLD}Выберите профиль [1-2]${CLR_RESET} [${CLR_YELLOW}1${CLR_RESET}]: ")" answer
        answer="${answer:-1}"

        case "${answer}" in
            1)
                UPS_PROFILE="default"
                break
                ;;
            2)
                UPS_PROFILE="later"
                break
                ;;
            *)
                echo -e "${CLR_RED}Неверный выбор. Пожалуйста, введите 1 или 2.${CLR_RESET}"
                ;;
        esac
    done

    echo
    echo -e "${CLR_GREEN}✓ Поддержка ИБП включена (${UPS_PROFILE}).${CLR_RESET}"
}
