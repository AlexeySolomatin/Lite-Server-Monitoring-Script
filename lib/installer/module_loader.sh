#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Загрузчик метаданных модулей
# Путь: lib/installer/module_loader.sh
# ==============================================================================


set -Eeuo pipefail


[[ -n "${LSM_MODULE_LOADER_LOADED:-}" ]] && return 0
readonly LSM_MODULE_LOADER_LOADED=1



LSM_MODULES_DIR="${LSM_MODULES_DIR:-${LSM_ROOT}/modules}"



#
# Загрузка manifest.conf
#

module_load_manifest()
{

    local module="${1:-}"

    local manifest="${LSM_MODULES_DIR}/${module}/manifest.conf"


    [[ -f "${manifest}" ]] || return 1


    unset MODULE_NAME
    unset MODULE_DESCRIPTION
    unset MODULE_VERSION
    unset MODULE_AUTHOR
    unset MODULE_DEPENDS
    unset MODULE_SERVICES
    unset MODULE_TIMER


    # shellcheck disable=SC1090
    source "${manifest}"


}



#
# Получение параметра модуля
#

module_get()
{

    local module="$1"
    local field="$2"


    module_load_manifest "${module}" || return 1


    case "${field}" in

        name)
            echo "${MODULE_NAME:-${module}}"
        ;;


        description)
            echo "${MODULE_DESCRIPTION:-Нет описания}"
        ;;


        version)
            echo "${MODULE_VERSION:-unknown}"
        ;;


        depends)
            echo "${MODULE_DEPENDS:-}"
        ;;


        services)
            echo "${MODULE_SERVICES:-}"
        ;;


        timer)
            echo "${MODULE_TIMER:-}"
        ;;


    esac

}



#
# Полная информация
#

module_info()
{

    local module="$1"


    module_load_manifest "${module}" || {

        echo "Модуль ${module} не найден"

        return 1

    }



cat <<EOF

Модуль:
  ${MODULE_NAME:-${module}}

Описание:
  ${MODULE_DESCRIPTION:-нет}

Версия:
  ${MODULE_VERSION:-unknown}

Зависимости:
  ${MODULE_DEPENDS:-нет}

Сервисы:
  ${MODULE_SERVICES:-нет}

Таймеры:
  ${MODULE_TIMER:-нет}

EOF


}
