#!/usr/bin/env bash
# shellcheck disable=SC2034
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Telegram Configuration Screen
# -----------------------------------------------------------------------------

set -Eeuo pipefail

TG_BOT_TOKEN=""
TG_CHAT_ID=""

screen_telegram() {
    wizard_header

    echo -e "${CLR_BOLD}Настройка уведомлений в Telegram:${CLR_RESET}"
    echo "Для отправки алертов требуется токен бота и ID чата получателя."
    echo -e "  ${CLR_CYAN}•${CLR_RESET} Создать бота и получить токен: ${CLR_YELLOW}@BotFather${CLR_RESET}"
    echo -e "  ${CLR_CYAN}•${CLR_RESET} Узнать ваш Chat ID: ${CLR_YELLOW}@userinfobot${CLR_RESET} или ${CLR_YELLOW}@getmyid_bot${CLR_RESET}"
    echo

    # Запрос Bot Token с валидацией
    TG_BOT_TOKEN=""
    while [[ -z "${TG_BOT_TOKEN}" ]]; do
        wizard_input "Введите Bot Token" "TG_BOT_TOKEN"
        if [[ -z "${TG_BOT_TOKEN}" ]]; then
            echo -e "${CLR_RED}Токен бота не может быть пустым. Попробуйте снова.${CLR_RESET}"
        fi
    done

    # Запрос Chat ID с валидацией
    TG_CHAT_ID=""
    while [[ -z "${TG_CHAT_ID}" ]]; do
        wizard_input "Введите Chat ID (личный или группы)" "TG_CHAT_ID"
        if [[ -z "${TG_CHAT_ID}" ]]; then
            echo -e "${CLR_RED}Chat ID не может быть пустым. Попробуйте снова.${CLR_RESET}"
        fi
    done

    echo
    echo -e "${CLR_GREEN}✓ Параметры Telegram успешно сохранены.${CLR_RESET}"
}
