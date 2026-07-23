#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Шаг инсталлятора 05: Установка модулей мониторинга
# Путь: installer/steps/05_modules.sh
# ==============================================================================

set -Eeuo pipefail

step_modules() {
    if declare -f log_info >/dev/null 2>&1; then
        log_info "Установка выбранных модулей мониторинга..."
    else
        echo "[i] Установка выбранных модулей мониторинга..."
    fi

    local modules_dir="${LSM_ROOT:-/opt/lsm}/modules"

    # Если массив SELECTED_MODULES пуст или не объявлен, задаем набор по умолчанию
    if [[ -z "${SELECTED_MODULES:-}" || ${#SELECTED_MODULES[@]} -eq 0 ]]; then
        SELECTED_MODULES=("disk" "system" "temperature" "smart" "login" "docker")
    fi

    if declare -f log_info >/dev/null 2>&1; then
        log_info "Выбранные модули: ${SELECTED_MODULES[*]}"
    else
        echo "[i] Выбранные модули: ${SELECTED_MODULES[*]}"
    fi

    for module in "${SELECTED_MODULES[@]}"; do
        local installer="${modules_dir}/${module}/install.sh"

        if [[ -f "${installer}" ]]; then
            if declare -f log_info >/dev/null 2>&1; then
                log_info "Запуск инсталлятора модуля: ${module}..."
            else
                echo "[i] Запуск инсталлятора модуля: ${module}..."
            fi

            bash "${installer}"
        else
            if declare -f log_warn >/dev/null 2>&1; then
                log_warn "Инсталлятор модуля '${module}' не найден по пути ${installer}, пропуск."
            else
                echo "[!] Предупреждение: Инсталлятор модуля '${module}' не найден по пути ${installer}, пропуск." >&2
            fi
        fi
    done

    if declare -f log_success >/dev/null 2>&1; then
        log_success "Все выбранные модули мониторинга успешно установлены."
    else
        echo "[+] Все выбранные модули мониторинга успешно установлены."
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    LSM_ROOT="${LSM_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
    export LSM_ROOT

    if [[ -f "${LSM_ROOT}/lib/core/common.sh" ]]; then
        # shellcheck source=/dev/null
        source "${LSM_ROOT}/lib/core/common.sh"
    fi

    if [[ -f "${LSM_ROOT}/lib/core/ui.sh" ]]; then
        # shellcheck source=/dev/null
        source "${LSM_ROOT}/lib/core/ui.sh"
    fi

    step_modules
fi
