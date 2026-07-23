#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# TUI backend
# Путь: lib/tui/dialog.sh
# ==============================================================================


set -Eeuo pipefail


tui_check()
{

    if ! command -v dialog >/dev/null 2>&1
    then

        log_error "Не найден пакет dialog."

        return 1

    fi

}



tui_msg()
{

    local title="$1"
    local text="$2"


    dialog \
        --title "${title}" \
        --msgbox "${text}" \
        10 60

}



tui_menu()
{

    dialog \
        --clear \
        --title "$1" \
        --menu "$2" \
        20 70 10 \
        "${@:3}"

}
