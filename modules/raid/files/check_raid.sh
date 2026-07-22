#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# RAID Monitor
# -----------------------------------------------------------------------------

set -Eeuo pipefail

# Сброс локали для предсказуемого вывода mdadm
export LC_ALL=C
export LANG=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

#
# Конфигурация
#

CONFIG_FILE="/etc/lsm/modules/raid.conf"
if [[ -f "${CONFIG_FILE}" ]]; then
    # shellcheck source=/dev/null
    source "${CONFIG_FILE}"
fi

#
# Значения по умолчанию
#

NOTIFY_ON_FAILURE="${NOTIFY_ON_FAILURE:-true}"
NOTIFY_ON_RECOVERY="${NOTIFY_ON_RECOVERY:-true}"
IGNORE_ARRAYS="${IGNORE_ARRAYS:-}"

STATE_DIR="/var/lib/lsm/state"
STATE_FILE="${STATE_DIR}/raid_alert"
LOCK_FILE="${STATE_DIR}/raid_check.lock"
NOTIFY_SCRIPT="${PROJECT_ROOT}/lib/notifications/notify.sh"

#
# Проверки окружения
#

if [[ ! -f /proc/mdstat ]]; then
    echo "SKIP: Файл /proc/mdstat отсутствует (RAID не используется)."
    exit 0
fi

if ! command -v mdadm &>/dev/null; then
    echo "SKIP: Утилита 'mdadm' не найдена в системе."
    exit 0
fi

if [[ "${EUID}" -ne 0 ]]; then
    echo "SKIP: Для работы с mdadm требуются права root."
    exit 0
fi

# Гарантируем наличие директории ДО открытия файла блокировки
mkdir -p "${STATE_DIR}"

(
    # Защита от параллельного запуска
    flock -n 200 || exit 0

    ALERT_TRIGGERED=0
    ALERT_MSG=""

    #
    # Проверка каждого массива md
    #
    while IFS= read -r MD_NAME; do
        [[ -z "${MD_NAME}" ]] && continue

        MD_DEVICE="/dev/${MD_NAME}"

        #
        # Пропуск игнорируемых массивов (поддержка md0 и /dev/md0)
        #
        SKIP=false
        for ARRAY in ${IGNORE_ARRAYS}; do
            ARRAY_CLEAN="${ARRAY#/dev/}"
            if [[ "${MD_NAME}" == "${ARRAY_CLEAN}" ]]; then
                SKIP=true
                break
            fi
        done

        [[ "${SKIP}" == true ]] && continue

        #
        # Запрос состояния массива
        #
        DETAIL_OUTPUT=$(mdadm --detail "${MD_DEVICE}" 2>/dev/null || true)

        if [[ -z "${DETAIL_OUTPUT}" ]]; then
            continue
        fi

        # Проверка на сбои (degraded, failed, inactive)
        if echo "${DETAIL_OUTPUT}" | grep -i "State :" | grep -qE "degraded|failed|inactive"; then
            ALERT_TRIGGERED=1

            STATUS_LINE=$(echo "${DETAIL_OUTPUT}" | grep -i "State :" | sed 's/.*State ://' | xargs || true)
            ALERT_MSG="${ALERT_MSG}\n- ${MD_DEVICE}: ${STATUS_LINE:-unknown}"
        fi

    done < <(awk '/^md/ {print $1}' /proc/mdstat 2>/dev/null || true)

    #
    # Отправка оповещений
    #
    if [[ -f "${NOTIFY_SCRIPT}" ]]; then
        # shellcheck source=/dev/null
        source "${NOTIFY_SCRIPT}"

        if (( ALERT_TRIGGERED == 1 )); then
            if [[ ! -f "${STATE_FILE}" ]]; then
                touch "${STATE_FILE}"

                if [[ "${NOTIFY_ON_FAILURE}" == "true" ]]; then
                    notify "raid" "CRITICAL" "❌ Ошибка в массиве Software RAID:${ALERT_MSG}"
                fi
            fi
        else
            if [[ -f "${STATE_FILE}" ]]; then
                rm -f "${STATE_FILE}"

                if [[ "${NOTIFY_ON_RECOVERY}" == "true" ]]; then
                    notify "raid" "OK" "✅ Состояние Software RAID массивов восстановлено (Healthy)."
                fi
            fi
        fi
    fi

) 200>"${LOCK_FILE}"
