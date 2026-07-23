#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# CLI Команда: Самодиагностика и проверка состояния LSM (Doctor)
# Путь: commands/doctor.sh
# ==============================================================================

set -Eeuo pipefail

LSM_ROOT="${LSM_ROOT:-/opt/lsm}"

# Подключение базовых библиотек
if [[ -f "${LSM_ROOT}/lib/core/common.sh" ]]; then
    # shellcheck source=/dev/null
    source "${LSM_ROOT}/lib/core/common.sh"
fi

if [[ -f "${LSM_ROOT}/lib/core/ui.sh" ]]; then
    # shellcheck source=/dev/null
    source "${LSM_ROOT}/lib/core/ui.sh"
fi

if [[ -f "${LSM_ROOT}/lib/core/report.sh" ]]; then
    # shellcheck source=/dev/null
    source "${LSM_ROOT}/lib/core/report.sh"
fi

# Вспомогательная функция проверки наличия директории
check_dir() {
    local dir="$1"
    if [[ -d "${dir}" ]]; then
        if declare -f log_success >/dev/null 2>&1; then
            log_success "Директория существует: ${dir}"
        else
            echo "[+] Директория существует: ${dir}"
        fi
    else
        if declare -f log_error >/dev/null 2>&1; then
            log_error "Директория отсутствует: ${dir}"
        else
            echo "[-] Директория отсутствует: ${dir}" >&2
        fi
    fi
}

# ------------------------------------------------------------------------------
# Основной ход выполнения диагностики
# ------------------------------------------------------------------------------

if declare -f ui_section >/dev/null 2>&1; then
    ui_section "Диагностика Lite Server Monitor (LSM)"
else
    echo "=========================================="
    echo "  Диагностика Lite Server Monitor (LSM)"
    echo "=========================================="
fi

echo ""

# 1. Проверка прав Root
echo "--- [1/6] Проверка прав доступа ---"
if [[ ${EUID} -eq 0 ]]; then
    if declare -f log_success >/dev/null 2>&1; then
        log_success "Скрипт запущен с правами root"
    else
        echo "[+] Скрипт запущен с правами root"
    fi
else
    if declare -f log_error >/dev/null 2>&1; then
        log_error "Скрипт запущен без прав root (требуются привилегии)"
    else
        echo "[-] Требуются права root" >&2
    fi
fi

# 2. Проверка ключевых директорий
echo ""
echo "--- [2/6] Проверка системных директорий LSM ---"
check_dir "/etc/lsm"
check_dir "/opt/lsm"
check_dir "/var/lib/lsm"
check_dir "/var/log/lsm"

# 3. Проверка служб Systemd
echo ""
echo "--- [3/6] Системные службы LSM ---"
systemctl list-unit-files "lsm-*.service" 2>/dev/null || echo "[i] Службы lsm-*.service не найдены."

# 4. Проверка таймеров Systemd
echo ""
echo "--- [4/6] Системные таймеры LSM ---"
systemctl list-timers "lsm-*.timer" --all 2>/dev/null || echo "[i] Таймеры lsm-*.timer не найдены."

# 5. Проверка активных предупреждений (Переиспользование lib/core/report.sh)
echo ""
echo "--- [5/6] Состояние предупреждений и алертов ---"
if declare -f report_get_active_alerts >/dev/null 2>&1; then
    report_get_active_alerts
else
    echo "[!] Модуль генерации отчетов (report.sh) недоступен."
fi

# 6. Диагностика модулей мониторинга (Переиспользование lib/core/report.sh)
echo ""
echo "--- [6/6] Статус модулей мониторинга ---"
if declare -f report_collect_modules >/dev/null 2>&1; then
    report_collect_modules
else
    echo "[!] Не удалось выполнить опрос модулей мониторинга."
fi

echo ""
if declare -f log_success >/dev/null 2>&1; then
    log_success "Диагностика системы завершена."
fi
