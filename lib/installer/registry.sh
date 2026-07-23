#!/usr/bin/env bash
#
# ==============================================================================
# Lite Server Monitor (LSM)
# Реестр компонентов установки
# Путь: lib/installer/registry.sh
# ==============================================================================


[[ -n "${LSM_INSTALL_REGISTRY_LOADED:-}" ]] && return
readonly LSM_INSTALL_REGISTRY_LOADED=1


declare -a LSM_COMPONENTS=()


#
# Регистрация компонента
#
registry_add() {

    local name="$1"

    LSM_COMPONENTS+=("${name}")

}


#
# Получить список компонентов
#
registry_list() {

    printf "%s\n" "${LSM_COMPONENTS[@]}"

}


#
# Проверка компонента
#
registry_exists() {

    local name="$1"

    for component in "${LSM_COMPONENTS[@]}"; do

        [[ "${component}" == "${name}" ]] && return 0

    done

    return 1

}


#
# Загрузка стандартного набора
#
registry_load_default() {


    registry_add "system"
    registry_add "disk"
    registry_add "smart"
    registry_add "temperature"
    registry_add "raid"
    registry_add "ups"
    registry_add "login"
    registry_add "fail2ban"
    registry_add "core"


}
