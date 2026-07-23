#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Реестр компонентов установки
# Путь: lib/installer/registry.sh
# ==============================================================================

set -Eeuo pipefail

[[ -n "${LSM_INSTALL_REGISTRY_LOADED:-}" ]] && return 0
readonly LSM_INSTALL_REGISTRY_LOADED=1


declare -A LSM_COMPONENTS_NAME
declare -A LSM_COMPONENTS_DESC
declare -A LSM_COMPONENTS_ENABLED


#
# Добавление компонента
#
registry_add() {

    local id="$1"
    local name="${2:-$1}"
    local description="${3:-}"

    LSM_COMPONENTS_NAME["${id}"]="${name}"
    LSM_COMPONENTS_DESC["${id}"]="${description}"
    LSM_COMPONENTS_ENABLED["${id}"]="false"

}


#
# Получить список компонентов
#
registry_list() {

    printf "%s\n" "${!LSM_COMPONENTS_NAME[@]}"

}


#
# Проверка наличия
#
registry_exists() {

    local id="$1"

    [[ -n "${LSM_COMPONENTS_NAME[$id]:-}" ]]

}


#
# Включить компонент
#
registry_enable() {

    local id="$1"

    if registry_exists "${id}"; then
        LSM_COMPONENTS_ENABLED["${id}"]="true"
    fi

}


#
# Выключить компонент
#
registry_disable() {

    local id="$1"

    if registry_exists "${id}"; then
        LSM_COMPONENTS_ENABLED["${id}"]="false"
    fi

}


#
# Проверка выбран
#
registry_is_enabled() {

    local id="$1"

    [[ "${LSM_COMPONENTS_ENABLED[$id]:-false}" == "true" ]]

}


#
# Загрузка стандартного набора
#
registry_load_default() {


    registry_add \
        "system" \
        "Система" \
        "CPU, RAM, нагрузка"


    registry_add \
        "disk" \
        "Диски" \
        "Свободное место"


    registry_add \
        "smart" \
        "SMART" \
        "Состояние HDD/SSD"


    registry_add \
        "temperature" \
        "Температура" \
        "Контроль температуры"


    registry_add \
        "raid" \
        "RAID" \
        "Состояние mdadm"


    registry_add \
        "ups" \
        "ИБП" \
        "Контроль APC UPS"


    registry_add \
        "login" \
        "Входы" \
        "SSH авторизация"


    registry_add \
        "fail2ban" \
        "Fail2Ban" \
        "Блокировки"


    registry_add \
        "core" \
        "Ядро LSM" \
        "Служебные компоненты"


}
