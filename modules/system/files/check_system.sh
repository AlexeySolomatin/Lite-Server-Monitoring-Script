#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# System Monitor
# -----------------------------------------------------------------------------

set -Eeuo pipefail

# Сброс локали для стандартизации вывода системных команд
export LC_ALL=C
export LANG=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

#
# Конфигурация
#

CONFIG_FILE="/etc/lsm/modules/system.conf"
if [[ -f "${CONFIG_FILE}" ]]; then
    # shellcheck source=/dev/null
    source "${CONFIG_FILE}"
fi

#
# Значения по умолчанию
#

LOAD_WARNING="${LOAD_WARNING:-5.0}"
LOAD_CRITICAL="${LOAD_CRITICAL:-10.0}"

MEMORY_WARNING="${MEMORY_WARNING:-85}"
MEMORY_CRITICAL="${MEMORY_CRITICAL:-95}"

DISK_WARNING="${DISK_WARNING:-85}"
DISK_CRITICAL="${DISK_CRITICAL:-95}"

STATE_DIR="/var/lib/lsm/state"
STATUS_FILE="${STATE_DIR}/system.status"
LOCK_FILE="${STATE_DIR}/system_check.lock"

NOTIFY_SCRIPT="${PROJECT_ROOT}/lib/notifications/notify.sh"

# Гарантируем наличие директории ДО открытия файла блокировки
mkdir -p "${STATE_DIR}"

(
    # Защита от параллельного запуска
    flock -n 200 || exit 0

    STATUS="OK"
    ALERT_MESSAGES=()

    #
    # 1. Проверка CPU Load
    #
    if [[ -f /proc/loadavg ]]; then
        LOAD=$(awk '{print $1}' /proc/loadavg)

        # Масштабируем float в int (умножаем на 10) для точного сравнения в Bash
        LOAD_SCALE=$(awk -v l="${LOAD}" 'BEGIN {printf "%.0f", l * 10}')
        LOAD_WARN_SCALE=$(awk -v w="${LOAD_WARNING}" 'BEGIN {printf "%.0f", w * 10}')
        LOAD_CRIT_SCALE=$(awk -v c="${LOAD_CRITICAL}" 'BEGIN {printf "%.0f", c * 10}')

        if (( LOAD_SCALE >= LOAD_CRIT_SCALE )); then
            STATUS="CRITICAL"
            ALERT_MESSAGES+=("CPU Load критический: ${LOAD} (Порог: ${LOAD_CRITICAL})")
        elif (( LOAD_SCALE >= LOAD_WARN_SCALE )); then
            [[ "${STATUS}" != "CRITICAL" ]] && STATUS="WARNING"
            ALERT_MESSAGES+=("CPU Load высокий: ${LOAD} (Порог: ${LOAD_WARNING})")
        fi
    else
        LOAD="N/A"
    fi

    #
    # 2. Проверка RAM (через /proc/meminfo)
    #
    if [[ -f /proc/meminfo ]]; then
        MEM_TOTAL=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
        MEM_AVAIL=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)

        if [[ -n "${MEM_TOTAL}" && "${MEM_TOTAL}" -gt 0 ]]; then
            MEM_USED_KB=$(( MEM_TOTAL - MEM_AVAIL ))
            MEMORY_USED=$(( MEM_USED_KB * 100 / MEM_TOTAL ))

            if (( MEMORY_USED >= MEMORY_CRITICAL )); then
                STATUS="CRITICAL"
                ALERT_MESSAGES+=("Память критический уровень: ${MEMORY_USED}% (Порог: ${MEMORY_CRITICAL}%)")
            elif (( MEMORY_USED >= MEMORY_WARNING )); then
                [[ "${STATUS}" != "CRITICAL" ]] && STATUS="WARNING"
                ALERT_MESSAGES+=("Память высокий уровень: ${MEMORY_USED}% (Порог: ${MEMORY_WARNING}%)")
            fi
        else
            MEMORY_USED="N/A"
        fi
    else
        MEMORY_USED="N/A"
    fi

    #
    # 3. Проверка корневого раздела /
    #
    if command -v df &>/dev/null; then
        DISK_USED=$(df -P / | awk 'NR==2 {print $5}' | tr -d '%')

        if [[ -n "${DISK_USED}" ]]; then
            if (( DISK_USED >= DISK_CRITICAL )); then
                STATUS="CRITICAL"
                ALERT_MESSAGES+=("Корневой диск / критический уровень: ${DISK_USED}% (Порог: ${DISK_CRITICAL}%)")
            elif (( DISK_USED >= DISK_WARNING )); then
                [[ "${STATUS}" != "CRITICAL" ]] && STATUS="WARNING"
                ALERT_MESSAGES+=("Корневой диск / высокий уровень: ${DISK_USED}% (Порог: ${DISK_WARNING}%)")
            fi
        else
            DISK_USED="N/A"
        fi
    else
        DISK_USED="N/A"
    fi

    #
    # Сохранение локального отчёта о состоянии
    #
    cat > "${STATUS_FILE}" <<EOF
STATUS=${STATUS}
LOAD=${LOAD}
MEMORY=${MEMORY_USED}
DISK=${DISK_USED}
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
EOF

    #
    # Отправка уведомления через центральный диспетчер
    #
    if [[ -f "${NOTIFY_SCRIPT}" ]]; then
        # shellcheck source=/dev/null
        source "${NOTIFY_SCRIPT}"

        if [[ "${STATUS}" != "OK" ]]; then
            DETAILS=$(printf "\n- %s" "${ALERT_MESSAGES[@]}")
            notify "system" "${STATUS}" "Обнаружены проблемы с системными ресурсами:${DETAILS}"
        else
            notify "system" "OK" "Все системные метрики (CPU, RAM, Диск) вернулись в норму."
        fi
    fi

) 200>"${LOCK_FILE}"
