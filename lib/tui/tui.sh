#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Главный контроллер TUI интерфейса
# Путь: lib/tui/tui.sh
# ==============================================================================


set -Eeuo pipefail


#
# Защита от повторной загрузки
#

[[ -n "${LSM_TUI_LOADED:-}" ]] && return 0
readonly LSM_TUI_LOADED=1



#
# Определение корня LSM
#

export LSM_ROOT="${LSM_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"



#
# Загрузка ядра LSM
#

source "${LSM_ROOT}/lib/core/common.sh"
source "${LSM_ROOT}/lib/core/colors.sh"
source "${LSM_ROOT}/lib/core/logging.sh"
source "${LSM_ROOT}/lib/core/ui.sh"



#
# Загрузка API модулей
#

source "${LSM_ROOT}/lib/installer/registry.sh"
source "${LSM_ROOT}/lib/installer/modules.sh"


if [[ -f "${LSM_ROOT}/lib/installer/module_loader.sh" ]]; then
    source "${LSM_ROOT}/lib/installer/module_loader.sh"
fi


if [[ -f "${LSM_ROOT}/lib/installer/module_validator.sh" ]]; then
    source "${LSM_ROOT}/lib/installer/module_validator.sh"
fi



#
# Пути TUI
#

readonly LSM_TUI_DIR="${LSM_ROOT}/lib/tui"



#
# Безопасная загрузка файлов
#

load_tui_file()
{

    local file="$1"


    if [[ ! -f "${file}" ]]; then

        log_error "Файл TUI не найден: ${file}"

        return 1

    fi


    # shellcheck source=/dev/null
    source "${file}"

}



#
# Проверка API зависимостей
#

tui_check_dependencies()
{

    local functions=(
        "registry_load_default"
        "module_loader_init"
        "module_loader_list"
    )


    for func in "${functions[@]}"
    do

        if ! declare -f "${func}" >/dev/null 2>&1; then

            log_error "Отсутствует обязательный API: ${func}"

            return 1

        fi

    done



    return 0

}



#
# Загрузка экранов
#

load_tui_screen()
{

    local screen="$1"


    local file="${LSM_TUI_DIR}/screens/${screen}.sh"


    if ! load_tui_file "${file}"; then

        log_error "Не удалось загрузить экран: ${screen}"

        return 1

    fi

}



#
# Загрузка TUI компонентов
#

load_tui_components()
{

    #
    # Ядро TUI
    #

    load_tui_file \
        "${LSM_TUI_DIR}/core.sh"



    #
    # Меню
    #

    load_tui_file \
        "${LSM_TUI_DIR}/menu.sh"



    #
    # Экраны
    #

    local screens=(
        "main"
        "modules"
        "install"
        "config"
        "report"
        "doctor"
    )


    for screen in "${screens[@]}"
    do

        load_tui_screen "${screen}"

    done

}



#
# Инициализация TUI
#

tui_init()
{

    if ! command -v dialog >/dev/null 2>&1; then

        log_error "Не установлен пакет dialog."

        log_info "Установите: apt install dialog"

        return 1

    fi



    if ! tui_check_dependencies; then

        return 1

    fi



    registry_load_default



    module_loader_init



    return 0

}



#
# Запуск интерфейса
#

tui_start()
{


    if ! tui_init; then

        log_error "Инициализация TUI завершилась ошибкой"

        exit 1

    fi



    if ! load_tui_components; then

        log_error "Не удалось загрузить компоненты TUI"

        exit 1

    fi



    clear


    screen_main

}



#
# Автозапуск
#

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    tui_start

fi
