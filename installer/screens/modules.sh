#!/usr/bin/env bash
# shellcheck disable=SC2034
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Экран выбора модулей
# Путь: installer/screens/modules.sh
# -----------------------------------------------------------------------------

set -Eeuo pipefail


SELECTED_MODULES=()


#
# Выбор модулей через реестр
#
screen_modules() {

    wizard_header


    echo -e "${CLR_BOLD}Выбор модулей для установки:${CLR_RESET}"
    echo "Настройте состав системы мониторинга."
    echo


    SELECTED_MODULES=()


    while read -r module; do


        [[ -z "${module}" ]] && continue


        local description
        local default


        description="$(registry_description "${module}")"
        default="$(registry_default "${module}")"


        # Служебный модуль ядра не выбирается вручную
        if [[ "${module}" == "core" ]]; then
            continue
        fi


        local answer="n"

        if [[ "${default}" == "yes" ]]; then
            answer="y"
        fi


        if wizard_yes_no \
            "Установить модуль ${module}: ${description}?" \
            "${answer}"
        then

            SELECTED_MODULES+=("${module}")

        fi


    done < <(registry_list | sort)



    #
    # Защита от пустой установки
    #
    if [[ ${#SELECTED_MODULES[@]} -eq 0 ]]; then


        echo
        echo -e "${CLR_YELLOW}Не выбран ни один модуль.${CLR_RESET}"


        if registry_exists "system"; then

            echo "Добавлен базовый модуль system."

            SELECTED_MODULES+=("system")

        fi


        wizard_pause

    fi

}
