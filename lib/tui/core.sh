#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Ядро TUI интерфейса
# Путь: lib/tui/core.sh
# ==============================================================================


set -Eeuo pipefail


[[ -n "${LSM_TUI_CORE_LOADED:-}" ]] && return 0
readonly LSM_TUI_CORE_LOADED=1



#
# Проверка наличия терминала
#

wizard_init_tty()
{

    if [[ ! -t 0 ]]; then

        log_error "TUI требует интерактивный терминал."

        return 1

    fi

}



#
# Очистка экрана
#

tui_clear()
{

    clear

}



#
# Сообщение пользователю
#

tui_msg()
{

    local title="${1:-LSM}"
    local message="${2:-}"


    dialog \
        --clear \
        --title "${title}" \
        --msgbox "${message}" \
        10 60


}



#
# Подтверждение действия
#

tui_confirm()
{

    local message="${1:-Продолжить?}"


    dialog \
        --clear \
        --yesno "${message}" \
        10 50


}



#
# Ошибка TUI
#

tui_error()
{

    tui_msg \
        "Ошибка" \
        "$1"

}



#
# Информационный блок
#

tui_info()
{

    tui_msg \
        "Информация" \
        "$1"

}

tui_clear()
{
    clear
}


tui_title()
{
    echo
    echo "======================================"
    echo "$1"
    echo "======================================"
    echo
}


tui_section()
{
    echo
    echo "--- $1 ---"
}


tui_success()
{
    echo "[ OK ] $1"
}


tui_error()
{
    echo "[ ОШИБКА ] $1"
}


tui_warning()
{
    echo "[ ВНИМАНИЕ ] $1"
}


tui_pause()
{
    read -rp "Нажмите Enter..."
}
