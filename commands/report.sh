#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# CLI Command: Report / Daily Digest Generator
# -----------------------------------------------------------------------------

set -Eeuo pipefail

LSM_ROOT="${LSM_ROOT:-/opt/lsm}"

# Подключение базовых библиотек
if [[ -f "${LSM_ROOT}/lib/core/common.sh" ]]; then source "${LSM_ROOT}/lib/core/common.sh"; fi
if [[ -f "${LSM_ROOT}/lib/core/ui.sh" ]]; then source "${LSM_ROOT}/lib/core/ui.sh"; fi

SEND_NOTIFICATION=false

# Разбор флагов
for arg in "$@"; do
    case "${arg}" in
        --send|-s)
            SEND_NOTIFICATION=true
            ;;
    esac
done

generate_report() {
    local hostname
    hostname="$(hostname -f 2>/dev/null || hostname)"

    echo "=================================================="
    echo "       LSM System Report - ${hostname}"
    echo "       Date: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=================================================="

    echo -e "\n--- System Info & Uptime ---"
    uptime 2>/dev/null || echo "Unable to fetch uptime"

    echo -e "\n--- Memory Usage ---"
    free -h 2>/dev/null || echo "Unable to fetch RAM stats"

    echo -e "\n--- Filesystem Usage ---"
    df -h -x tmpfs -x devtmpfs -x squashfs 2>/dev/null || echo "Unable to fetch disk stats"

    echo -e "\n--- Top 5 CPU Consuming Processes ---"
    ps aux --sort=-%cpu 2>/dev/null | head -n 6 || true

    echo -e "\n--- Top 5 RAM Consuming Processes ---"
    ps aux --sort=-%mem 2>/dev/null | head -n 6 || true

    echo -e "\n--- Active LSM Alerts ---"
    local state_dir="/var/lib/lsm/state"
    if [[ -d "${state_dir}" ]] && [[ $(ls -A "${state_dir}" 2>/dev/null) ]]; then
        for state_file in "${state_dir}"/*.state; do
            [[ -f "${state_file}" ]] || continue
            local module_name
            module_name="$(basename "${state_file}" .state)"
            local state_data
            state_data="$(cat "${state_file}")"
            echo "  - [ALERT] Module '${module_name}': ${state_data#*|}"
        done
    else
        echo "  All systems operational. No active alerts."
    fi
}

if [[ "${SEND_NOTIFICATION}" == "true" ]]; then
    # Генерация отчета во временный файл и отправка через notify
    report_output="$(generate_report)"
    
    if [[ -f "${LSM_ROOT}/lib/notifications/notify.sh" ]]; then
        "${LSM_ROOT}/lib/notifications/notify.sh" "daily_report" "OK" "${report_output}"
        log_success "Daily report successfully sent via notifications dispatcher."
    else
        log_error "Notification dispatcher script not found at ${LSM_ROOT}/lib/notifications/notify.sh"
        exit 1
    fi
else
    # Обычный вывод в консоль
    if declare -f ui_section >/dev/null 2>&1; then
        ui_section "LSM System Diagnostic Report"
    fi
    generate_report
    echo ""
    log_success "Report generated successfully."
fi
