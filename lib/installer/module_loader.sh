#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Загрузчик метаданных модулей
# Путь: lib/installer/module_loader.sh
# ==============================================================================


set -Eeuo pipefail


[[ -n "${LSM_MODULE_LOADER_LOADED:-}" ]] && return 0
readonly LSM_MODULE_LOADER_LOADED=1



#
# Корень проекта
#

LSM_ROOT="${LSM_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

LSM_MODULES_DIR="${LSM_MODULES_DIR:-${LSM_ROOT}/modules}"

export LSM_MODULES_DIR



#
# Метаданные текущего модуля
#

MODULE_ID=""
MODULE_NAME=""
MODULE_DESCRIPTION=""
MODULE_VERSION=""
MODULE_CATEGORY=""

MODULE_DEPENDENCIES=""
MODULE_REQUIRED_PACKAGES=""
MODULE_SERVICE=""
MODULE_TIMER=""



#
# Инициализация
#

module_loader_init()
{

    if [[ ! -d "${LSM_MODULES_DIR}" ]]; then

        log_warn "Каталог модулей отсутствует: ${LSM_MODULES_DIR}"

        return 1

    fi


    return 0

}



#
# Очистка метаданных
#

module_clear_metadata()
{

    MODULE_ID=""
    MODULE_NAME=""
    MODULE_DESCRIPTION=""
    MODULE_VERSION=""
    MODULE_CATEGORY=""

    MODULE_DEPENDENCIES=""
    MODULE_REQUIRED_PACKAGES=""
    MODULE_SERVICE=""
    MODULE_TIMER=""

}



#
# Загрузка manifest.conf
#

module_load_manifest()
{

    local module="${1:-}"


    if [[ -z "${module}" ]]; then

        return 1

    fi



    local manifest="${LSM_MODULES_DIR}/${module}/manifest.conf"



    if [[ ! -f "${manifest}" ]]; then

        log_warn "Manifest отсутствует: ${module}"

        return 1

    fi



    module_clear_metadata



    # shellcheck disable=SC1090
    source "${manifest}"



    return 0

}



#
# Список модулей
#

module_loader_list()
{

    if [[ ! -d "${LSM_MODULES_DIR}" ]]; then

        return 0

    fi


    {
        find "${LSM_MODULES_DIR}" \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
            -printf "%f\n" \
            2>/dev/null || true

    } | sort

}



#
# Получение имени
#

module_get_name()
{

    local module="${1:-}"


    if module_load_manifest "${module}"; then

        echo "${MODULE_NAME:-${module}}"

    else

        echo "${module}"

    fi

}



#
# Получение категории
#

module_get_category()
{

    local module="${1:-}"


    if module_load_manifest "${module}"; then

        echo "${MODULE_CATEGORY:-unknown}"

    else

        echo "unknown"

    fi

}



#
# Получение описания
#

module_get_description()
{

    local module="${1:-}"


    if module_load_manifest "${module}"; then

        echo "${MODULE_DESCRIPTION:-Нет описания}"

    else

        echo "Нет описания"

    fi

}



#
# Получение версии
#

module_get_version()
{

    local module="${1:-}"


    if module_load_manifest "${module}"; then

        echo "${MODULE_VERSION:-unknown}"

    else

        echo "unknown"

    fi

}



#
# Проверка manifest
#

module_has_manifest()
{

    local module="${1:-}"


    [[ -f "${LSM_MODULES_DIR}/${module}/manifest.conf" ]]

}



#
# Проверка модуля
#

module_validate()
{

    local module="${1:-}"


    if ! module_has_manifest "${module}"; then

        log_error "Модуль ${module}: отсутствует manifest.conf"

        return 1

    fi



    if [[ ! -f "${LSM_MODULES_DIR}/${module}/install.sh" ]]; then

        log_error "Модуль ${module}: отсутствует install.sh"

        return 1

    fi



    return 0

}



#
# Полная информация о модуле
#

module_info()
{

    local module="${1:-}"


    if ! module_load_manifest "${module}"; then

        return 1

    fi



cat <<EOF
ID: ${MODULE_ID}

Название: ${MODULE_NAME}

Описание: ${MODULE_DESCRIPTION}

Версия: ${MODULE_VERSION}

Категория: ${MODULE_CATEGORY}

Зависимости: ${MODULE_DEPENDENCIES:-нет}

Пакеты: ${MODULE_REQUIRED_PACKAGES:-нет}

Служба: ${MODULE_SERVICE:-нет}

Таймер: ${MODULE_TIMER:-нет}
EOF

}



#
# API для TUI
#

module_get_metadata()
{

    local module="${1:-}"


    module_info "${module}"

}
