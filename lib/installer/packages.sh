#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Библиотека управления пакетами APT
# Путь: lib/installer/packages.sh
# ==============================================================================

set -Eeuo pipefail

# Защита от повторного подключения файла
[[ -n "${LSM_PACKAGES_LOADED:-}" ]] && return 0
readonly LSM_PACKAGES_LOADED=1

# Флаг состояния обновления индексов APT
APT_UPDATED="${APT_UPDATED:-false}"

#
# Выполнение команды apt-get в неинтерактивном режиме
#
run_apt() {
    DEBIAN_FRONTEND=noninteractive \
        apt-get -y \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold" \
        "$@"
}

#
# Обновление индекса пакетов (выполняется только один раз за сессию)
#
update_package_cache() {
    if [[ "${APT_UPDATED}" == "true" ]]; then
        return 0
    fi

    if declare -f log_info >/dev/null 2>&1; then
        log_info "PACKAGES" "Обновление индекса пакетов APT..."
    else
        echo "[INFO] Обновление индекса пакетов APT..."
    fi

    if run_apt update -qq; then
        APT_UPDATED="true"
    else
        if declare -f log_error >/dev/null 2>&1; then
            log_error "PACKAGES" "Не удалось обновить индекс пакетов APT."
        else
            echo "Ошибка: Не удалось обновить индекс пакетов APT." >&2
        fi
        return 1
    fi
}

#
# Проверка, установлен ли пакет в системе
#
package_installed() {
    local package="${1:-}"

    if [[ -z "${package}" ]]; then
        return 1
    fi

    # Защита конвейера при подгруженном set -e -o pipefail
    { dpkg-query -W -f='${Status}' "${package}" 2>/dev/null || true; } | grep -q "install ok installed"
}

#
# Установка пакета (с автоматическим обновлением кэша при необходимости)
#
install_package() {
    local package="${1:-}"

    if [[ -z "${package}" ]]; then
        return 1
    fi

    if package_installed "${package}"; then
        if declare -f log_info >/dev/null 2>&1; then
            log_info "PACKAGES" "Пакет уже установлен: ${package}"
        fi
        return 0
    fi

    # Гарантируем актуальность индексов репозиториев перед установкой
    update_package_cache

    if declare -f log_info >/dev/null 2>&1; then
        log_info "PACKAGES" "Установка пакета: ${package}"
    fi

    run_apt install "${package}"
}
