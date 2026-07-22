#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# UPS Monitor
# -----------------------------------------------------------------------------

set -Eeuo pipefail

# Сброс локали
export LC_ALL=C
export LANG=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

#
# Конфигурация
#

CONFIG_FILE="/etc/lsm/modules/ups.conf"
if [[ -f "${CONFIG_FILE}" ]]; then
    # shellcheck source=/dev/null
    source "${CONFIG_FILE}"
fi

#
# Значения по умолчанию
#

BATTERY_WARNING="${BATTERY_WARNING:-50}"
BATTERY_CRITICAL="${BATTERY_CRITICAL:-20}"

NOTIFY_ON_BATTERY="${NOTIFY_ON_BATTERY:-true}"
NOTIFY_ON_LOW_BATTERY="${NOTIFY_ON_LOW_BATTERY:-true}"
NOTIFY_ON_RECOVERY="${NOTIFY_ON_RECOVERY:-true}"

STATE_DIR="/var/lib/lsm/state"
STATE_FILE="${STATE_DIR}/ups_state"
LOCK_FILE="${STATE_DIR}/ups_check.lock"
NOTIFY_SCRIPT="${PROJECT_ROOT}/lib/notifications/notify.sh"

#
# Проверка наличия apcaccess
#
if ! command -v apcaccess &>/dev/null; then
    echo "SKIP: Утилита 'apcaccess' не найдена в системе (apcupsd не установлен)."
    exit 0
fi

# Гарантируем наличие директории ДО открытия файла блокировки
mkdir -p "${STATE_DIR}"

(
    # Защита от параллельного запуска
    flock -n 200 || exit 0

    UPS_STATUS=$(apcaccess status 2>/dev/null || true)

    if [[ -z "${UPS_STATUS}" ]]; then
        echo "SKIP: Служба apcupsd не ответила на запрос apcaccess status."
        exit 0
    fi

    #
    # Извлечение и очистка параметров
    #
    STATUS_RAW=$(echo "${UPS_STATUS}" | awk -F': ' '/STATUS/ {print $2}' | xargs || true)
    CHARGE_RAW=$(echo "${UPS_STATUS}" | awk -F': ' '/BCHARGE/ {print $2}' | awk '{print $1}' || true)
    TIMELEFT_RAW=$(echo "${UPS_STATUS}" | awk -F': ' '/TIMELEFT/ {print $2}' | xargs || true)

    CHARGE_INT=100
    if [[ -n "${CHARGE_RAW}" ]]; then
        CHARGE_INT=${CHARGE_RAW%.*}
    fi

    #
    # Определение текущего состояния ИБП
    #
    CURRENT_STATE="ONLINE"

    if [[ "${STATUS_RAW}" != *"ONLINE"* ]]; then
        if (( CHARGE_INT <= BATTERY_CRITICAL )); then
            CURRENT_STATE="CRITICAL"
        elif (( CHARGE_INT <= BATTERY_WARNING )); then
            CURRENT_STATE="WARNING"
        else
            CURRENT_STATE="ON_BATTERY"
        fi
    fi

    PREVIOUS_STATE=""
    if [[ -f "${STATE_FILE}" ]]; then
        PREVIOUS_STATE=$(cat "${STATE_FILE}" || true)
    fi

    #
    # Обработка смены состояний и отправка уведомлений
    #
    if [[ "${PREVIOUS_STATE}" != "${CURRENT_STATE}" ]]; then
        if [[ -f "${NOTIFY_SCRIPT}" ]]; then
            # shellcheck source=/dev/null
            source "${NOTIFY_SCRIPT}"

            case "${CURRENT_STATE}" in
                "ON_BATTERY")
                    if [[ "${NOTIFY_ON_BATTERY}" == "true" ]]; then
                        notify "ups" "WARNING" "🔋 ИБП перешел на питание от батареи!\n- Заряд: ${CHARGE_RAW:-unknown}%\n- Осталось времени: ${TIMELEFT_RAW:-unknown}"
                    fi
                    ;;
                "WARNING")
                    if [[ "${NOTIFY_ON_LOW_BATTERY}" == "true" ]]; then
                        notify "ups" "WARNING" "⚠️ Низкий уровень заряда ИБП!\n- Заряд: ${CHARGE_RAW:-unknown}%\n- Осталось времени: ${TIMELEFT_RAW:-unknown}"
                    fi
                    ;;
                "CRITICAL")
                    if [[ "${NOTIFY_ON_LOW_BATTERY}" == "true" ]]; then
                        notify "ups" "CRITICAL" "🚨 Критический уровень заряда ИБП!\n- Заряд: ${CHARGE_RAW:-unknown}%\n- Осталось времени: ${TIMELEFT_RAW:-unknown}"
                    fi
                    ;;
                "ONLINE")
                    if [[ -n "${PREVIOUS_STATE}" && "${NOTIFY_ON_RECOVERY}" == "true" ]]; then
                        notify "ups" "OK" "✅ Питание ИБП восстановлено (Работа от сети)."
                    fi
                    ;;
            esac
        fi

        # Фиксируем актуальное состояние
        echo "${CURRENT_STATE}" > "${STATE_FILE}"
    fi

) 200>"${LOCK_FILE}"
