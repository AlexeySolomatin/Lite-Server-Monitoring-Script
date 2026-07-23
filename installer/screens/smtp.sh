#!/usr/bin/env bash
# shellcheck disable=SC2034
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# SMTP Configuration Screen
# -----------------------------------------------------------------------------

set -Eeuo pipefail

EMAIL_ENABLED="true"
SMTP_PROFILE=""
SMTP_SERVER=""
SMTP_PORT=""
SMTP_TLS=""
SMTP_USER=""
SMTP_PASS=""
SMTP_FROM=""
ALERT_EMAIL=""

screen_smtp() {
    wizard_header

    echo -e "${CLR_BOLD}Настройка отправки Email (SMTP):${CLR_RESET}"
    echo "Укажите параметры подключения к почтовому серверу для отправки отчетов и алертов."
    echo

    EMAIL_ENABLED="true"

    echo -e "  ${CLR_CYAN}1)${CLR_RESET} Gmail (port 587, STARTTLS)"
    echo -e "  ${CLR_CYAN}2)${CLR_RESET} Yandex (port 465, SSL/TLS)"
    echo -e "  ${CLR_CYAN}3)${CLR_RESET} Ручная настройка (Custom SMTP)"
    echo

    while true; do
        read -rp "$(echo -e "${CLR_BOLD}Выберите провайдера [1-3]${CLR_RESET} [${CLR_YELLOW}1${CLR_RESET}]: ")" answer
        answer="${answer:-1}"

        case "${answer}" in
            1)
                SMTP_PROFILE="gmail"
                SMTP_SERVER="smtp.gmail.com"
                SMTP_PORT="587"
                SMTP_TLS="on"
                break
                ;;
            2)
                SMTP_PROFILE="yandex"
                SMTP_SERVER="smtp.yandex.ru"
                SMTP_PORT="465"
                SMTP_TLS="on"
                break
                ;;
            3)
                SMTP_PROFILE="manual"
                wizard_input "SMTP Сервер" "SMTP_SERVER"
                wizard_input "SMTP Порт" "SMTP_PORT" "587"
                wizard_input "Использовать TLS (on/off)" "SMTP_TLS" "on"
                break
                ;;
            *)
                echo -e "${CLR_RED}Неверный выбор. Пожалуйста, введите 1, 2 или 3.${CLR_RESET}"
                ;;
        esac
    done

    echo

    # Запрос логина (Email)
    SMTP_USER=""
    while [[ -z "${SMTP_USER}" ]]; do
        wizard_input "Имя пользователя (Логин / Email)" "SMTP_USER"
        if [[ -z "${SMTP_USER}" ]]; then
            echo -e "${CLR_RED}Логин не может быть пустым. Попробуйте снова.${CLR_RESET}"
        fi
    done

    # Скрытый запрос пароля приложения
    SMTP_PASS=""
    while [[ -z "${SMTP_PASS}" ]]; do
        wizard_mask_input "Пароль приложения (App Password)" "SMTP_PASS"
        if [[ -z "${SMTP_PASS}" ]]; then
            echo -e "${CLR_RED}Пароль не может быть пустым. Попробуйте снова.${CLR_RESET}"
        fi
    done

    # Email отправителя и получателя
    wizard_input "Email отправителя" "SMTP_FROM" "${SMTP_USER}"

    ALERT_EMAIL=""
    while [[ -z "${ALERT_EMAIL}" ]]; do
        wizard_input "Email получателя алертов" "ALERT_EMAIL" "${SMTP_USER}"
        if [[ -z "${ALERT_EMAIL}" ]]; then
            echo -e "${CLR_RED}Email получателя не может быть пустым. Попробуйте снова.${CLR_RESET}"
        fi
    done

    echo
    echo -e "${CLR_GREEN}✓ Параметры Email (SMTP) успешно сохранены.${CLR_RESET}"
}
