#!/usr/bin/env bash
# shellcheck disable=SC2034
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Module Selection Screen
# -----------------------------------------------------------------------------

set -Eeuo pipefail

SELECTED_MODULES=()

screen_modules() {
    wizard_header

    echo -e "${CLR_BOLD}Выбор модулей для установки:${CLR_RESET}"
    echo "Ответьте на вопросы, чтобы сформировать состав системы мониторинга."
    echo

    SELECTED_MODULES=()

    if wizard_yes_no "Установить мониторинг дискового пространства (Disk)?" "y"; then
        SELECTED_MODULES+=("disk")
    fi

    if wizard_yes_no "Установить мониторинг системных ресурсов CPU/RAM (System)?" "y"; then
        SELECTED_MODULES+=("system")
    fi

    if wizard_yes_no "Установить мониторинг состояния накопителей (SMART)?" "y"; then
        SELECTED_MODULES+=("smart")
    fi

    if wizard_yes_no "Установить мониторинг RAID-массивов (RAID)?" "n"; then
        SELECTED_MODULES+=("raid")
    fi

    if wizard_yes_no "Установить мониторинг температуры компонентов (Temperature)?" "y"; then
        SELECTED_MODULES+=("temperature")
    fi

    if wizard_yes_no "Установить мониторинг входов в систему (Login)?" "y"; then
        SELECTED_MODULES+=("login")
    fi

    if wizard_yes_no "Установить мониторинг блокировок Fail2Ban?" "n"; then
        SELECTED_MODULES+=("fail2ban")
    fi

    # Проверка: если пользователь ничего не выбрал, подключаем базовый модуль
    if [[ ${#SELECTED_MODULES[@]} -eq 0 ]]; then
        echo
        echo -e "${CLR_YELLOW}Не выбрано ни одного модуля. По умолчанию подключен модуль 'system'.${CLR_RESET}"
        SELECTED_MODULES+=("system")
        wizard_pause
    fi
}
