#!/usr/bin/env bash
# shellcheck disable=SC2034
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Notification Configuration Screen
# -----------------------------------------------------------------------------

set -Eeuo pipefail

NOTIFICATION_METHOD="none"

screen_notifications() {
    wizard_header

    echo -e "${CLR_BOLD}Выбор способа отправки уведомлений:${CLR_RESET}"
    echo "Укажите, куда система должна отправлять алерты и ежедневный отчет."
    echo
    echo -e "  ${CLR_CYAN}1)${CLR_RESET} Без уведомлений (только локальные состояния)"
    echo -e "  ${CLR_CYAN}2)${CLR_RESET} Telegram-бот ${CLR_YELLOW}(Рекомендуется)${CLR_RESET}"
    echo -e "  ${CLR_CYAN}3)${CLR_RESET} Email (SMTP)"
    echo -e "  ${CLR_CYAN}4)${CLR_RESET} Telegram + Email"
    echo

    while true; do
        read -rp "$(echo -e "${CLR_BOLD}Выберите вариант [1-4]${CLR_RESET} [${CLR_YELLOW}2${CLR_RESET}]: ")" answer
        answer="${answer:-2}"

        case "${answer}" in
            1)
                NOTIFICATION_METHOD="none"
                break
                ;;
            2)
                NOTIFICATION_METHOD="telegram"
                break
                ;;
            3)
                NOTIFICATION_METHOD="email"
                break
                ;;
            4)
                NOTIFICATION_METHOD="both"
                break
                ;;
            *)
                echo -e "${CLR_RED}Неверный выбор. Пожалуйста, введите число от 1 до 4.${CLR_RESET}"
                ;;
        esac
    done
}
