#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Экран управления модулями
# Путь: lib/tui/screens/modules.sh
# ==============================================================================


set -Eeuo pipefail


[[ -n "${LSM_TUI_SCREEN_MODULES_LOADED:-}" ]] && return 0
readonly LSM_TUI_SCREEN_MODULES_LOADED=1



#
# Загрузка API модулей
#

if [[ -f "${LSM_ROOT}/lib/installer/modules.sh" ]]; then
    # shellcheck source=/dev/null
    source "${LSM_ROOT}/lib/installer/modules.sh"
fi



#
# Показ списка модулей
#

screen_modules_list()
{

    local modules


    modules="$(modules_list || true)"


    if [[ -z "${modules}" ]]; then

        tui_message \
            "Модули LSM" \
            "Доступные модули отсутствуют."

        return

    fi



    tui_message \
        "Модули LSM" \
        "${modules}"

}



#
# Установка модуля
#

screen_modules_install()
{

    local module


    module="$(
        dialog \
            --clear \
            --title "Установка модуля" \
            --inputbox "Введите имя модуля:" \
            10 60 \
            3>&1 1>&2 2>&3
    )"



    [[ -z "${module}" ]] && return



    if modules_install "${module}"; then

        tui_message \
            "Установка завершена" \
            "Модуль '${module}' успешно установлен."

    else

        tui_message \
            "Ошибка" \
            "Не удалось установить модуль '${module}'."

    fi

}



#
# Удаление модуля
#

screen_modules_remove()
{

    local module


    module="$(
        dialog \
            --clear \
            --title "Удаление модуля" \
            --inputbox "Введите имя модуля:" \
            10 60 \
            3>&1 1>&2 2>&3
    )"



    [[ -z "${module}" ]] && return



    if tui_confirm "Удалить модуль '${module}'?"; then


        if modules_remove "${module}"; then

            tui_message \
                "Удаление завершено" \
                "Модуль '${module}' удален."

        else

            tui_message \
                "Ошибка" \
                "Не удалось удалить модуль '${module}'."

        fi

    fi

}



#
# Основной экран
#

screen_modules()
{


while true
do


    tui_clear


    tui_menu_create \
        "Модули LSM" \
        "Управление компонентами мониторинга" \
        1 "Список модулей" \
        2 "Установить модуль" \
        3 "Удалить модуль" \
        0 "Назад"



    case "${TUI_MENU_RESULT}" in


        1)

            screen_modules_list

        ;;


        2)

            screen_modules_install

        ;;


        3)

            screen_modules_remove

        ;;


        0|*)

            break

        ;;


    esac


done


}
