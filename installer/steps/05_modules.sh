#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Step 05: Module Installation
# Path: installer/steps/05_modules.sh
# ==============================================================================

set -Eeuo pipefail


step_modules()
{

    log_info "Подготовка установки модулей..."


    #
    # Проверка выбора
    #

    if [[ -z "${SELECTED_MODULES+x}" ]]; then

        log_error "Список модулей не определен."

        return 1

    fi



    if [[ ${#SELECTED_MODULES[@]} -eq 0 ]]; then

        log_warn "Модули не выбраны."

        return 0

    fi



    printf '%s\n' \
        "Выбранные модули:"


    printf ' - %s\n' \
        "${SELECTED_MODULES[@]}"



    #
    # Проверка API
    #

    local required_functions=(
        "module_loader_init"
        "module_validate_all"
        "modules_install"
        "registry_resolve_order"
        "registry_exists"
    )



    for func in "${required_functions[@]}"
    do

        if ! declare -f "${func}" >/dev/null 2>&1; then

            log_error \
            "Отсутствует API: ${func}"

            return 1

        fi

    done



    #
    # Инициализация
    #

    module_loader_init



    #
    # Проверка выбранных модулей
    #

    for module in "${SELECTED_MODULES[@]}"
    do

        if ! registry_exists "${module}"; then

            log_error \
            "Модуль отсутствует в registry: ${module}"

            return 1

        fi

    done



    #
    # Resolve зависимостей
    #

    local install_order=()



    while read -r module
    do

        [[ -z "${module}" ]] && continue

        install_order+=("${module}")


    done < <(
        registry_resolve_order \
        "${SELECTED_MODULES[@]}"
    )



    if [[ ${#install_order[@]} -eq 0 ]]; then

        log_error \
        "Не удалось определить порядок установки."

        return 1

    fi



    log_info "Порядок установки:"

    printf ' -> %s\n' \
        "${install_order[@]}"



    #
    # Установка
    #

    for module in "${install_order[@]}"
    do


        log_info \
        "Проверка модуля: ${module}"



        if ! module_validate_all "${module}"; then

            log_error \
            "Проверка модуля не пройдена: ${module}"

            return 1

        fi



        log_info \
        "Установка модуля: ${module}"



        if ! modules_install "${module}"; then

            log_error \
            "Ошибка установки: ${module}"

            return 1

        fi



        log_success \
        "Модуль ${module} установлен."

    done



    log_success \
    "Все модули успешно установлены."

}



if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then


    LSM_ROOT="${LSM_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

    export LSM_ROOT


    source "${LSM_ROOT}/lib/core/common.sh"
    source "${LSM_ROOT}/lib/core/logging.sh"

    source "${LSM_ROOT}/lib/installer/module_loader.sh"
    source "${LSM_ROOT}/lib/installer/module_validator.sh"
    source "${LSM_ROOT}/lib/installer/modules.sh"
    source "${LSM_ROOT}/lib/installer/registry.sh"



    registry_load_default


    SELECTED_MODULES=("$@")


    step_modules

fi
