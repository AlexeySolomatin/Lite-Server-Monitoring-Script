#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Реестр модулей установки
# Путь: lib/installer/registry.sh
# ==============================================================================


set -Eeuo pipefail



[[ -n "${LSM_INSTALL_REGISTRY_LOADED:-}" ]] && return 0
readonly LSM_INSTALL_REGISTRY_LOADED=1



#
# Пути
#

LSM_ROOT="${LSM_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

LSM_MODULES_DIR="${LSM_MODULES_DIR:-${LSM_ROOT}/modules}"



#
# Хранилище
#

declare -A LSM_MODULE_NAME
declare -A LSM_MODULE_DESCRIPTION
declare -A LSM_MODULE_VERSION
declare -A LSM_MODULE_CATEGORY
declare -A LSM_MODULE_DEPENDENCIES
declare -A LSM_MODULE_DEFAULT



declare -a LSM_MODULES=()



#
# Добавление модуля
#

registry_add()
{

    local module="$1"


    [[ -n "${module}" ]] || return 1



    if ! module_has_manifest "${module}"; then

        log_warn \
            "Модуль ${module}: отсутствует manifest.conf"

        return 1

    fi



    module_load_manifest "${module}"



    LSM_MODULES+=("${module}")



    LSM_MODULE_NAME["${module}"]="${MODULE_NAME:-${module}}"

    LSM_MODULE_DESCRIPTION["${module}"]="${MODULE_DESCRIPTION:-}"

    LSM_MODULE_VERSION["${module}"]="${MODULE_VERSION:-unknown}"

    LSM_MODULE_CATEGORY["${module}"]="${MODULE_CATEGORY:-unknown}"

    LSM_MODULE_DEPENDENCIES["${module}"]="${MODULE_DEPENDENCIES:-}"

    LSM_MODULE_DEFAULT["${module}"]="${MODULE_DEFAULT:-no}"

}



#
# Сканирование модулей
#

registry_scan()
{

    LSM_MODULES=()



    [[ -d "${LSM_MODULES_DIR}" ]] || return 0



    while read -r module
    do

        [[ -z "${module}" ]] && continue


        registry_add "${module}"


    done < <(
        {
            find "${LSM_MODULES_DIR}" \
                -mindepth 1 \
                -maxdepth 1 \
                -type d \
                -printf "%f\n" \
                2>/dev/null || true

        } | sort
    )

}



#
# Загрузка реестра
#

registry_load_default()
{

    registry_scan

}



#
# Проверка существования
#

registry_exists()
{

    local module="$1"


    [[ -n "${LSM_MODULE_NAME[$module]:-}" ]]

}



#
# Список модулей
#

registry_list()
{

    printf "%s\n" "${LSM_MODULES[@]}"

}



#
# Информация
#

registry_info()
{

    local module="$1"



    if ! registry_exists "${module}"; then

        return 1

    fi



    cat <<EOF

Модуль: ${module}

Название:
${LSM_MODULE_NAME[$module]}

Описание:
${LSM_MODULE_DESCRIPTION[$module]}

Категория:
${LSM_MODULE_CATEGORY[$module]}

Версия:
${LSM_MODULE_VERSION[$module]}

Зависимости:
${LSM_MODULE_DEPENDENCIES[$module]}

По умолчанию:
${LSM_MODULE_DEFAULT[$module]}

EOF

}



#
# Получение зависимостей
#

registry_dependencies()
{

    local module="$1"


    echo "${LSM_MODULE_DEPENDENCIES[$module]:-}"

}



#
# Формирование порядка установки
#

registry_resolve_order()
{

    local requested=("$@")


    local result=()



    for module in "${requested[@]}"
    do

        registry_resolve_module \
            "${module}" \
            result

    done



    printf "%s\n" "${result[@]}"

}



#
# Рекурсивный resolver
#

registry_resolve_module()
{

    local module="$1"

    local -n output="$2"



    for item in "${output[@]}"
    do

        [[ "${item}" == "${module}" ]] && return

    done



    local deps

    deps=$(registry_dependencies "${module}")



    for dep in ${deps}
    do

        registry_resolve_module \
            "${dep}" \
            output

    done



    output+=("${module}")

}
