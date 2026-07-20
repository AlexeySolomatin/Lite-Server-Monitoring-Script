#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Temperature Monitor
# -----------------------------------------------------------------------------

set -Eeuo pipefail

#
# Configuration
#

CONFIG_FILE="/etc/lsm/modules/temperature.conf"

[[ -f "${CONFIG_FILE}" ]] && source "${CONFIG_FILE}"

#
# Defaults
#

WARNING_TEMP="${WARNING_TEMP:-70}"
CRITICAL_TEMP="${CRITICAL_TEMP:-80}"

NOTIFY_ON_WARNING="${NOTIFY_ON_WARNING:-true}"
NOTIFY_ON_RECOVERY="${NOTIFY_ON_RECOVERY:-true}"

#
# Paths
#

STATE_DIR="/var/lib/lsm/state"

LOCK_FILE="${STATE_DIR}/temperature_check.lock"


(
    #
    # Prevent parallel execution
    #

    flock -n 200 || exit 0


    #
    # Read temperature
    #

    TEMP_DATA=$(sensors 2>/dev/null || true)


    if [[ -z "${TEMP_DATA}" ]]; then
        exit 0
    fi


    #
    # Find highest temperature
    #

    CURRENT_TEMP=$(
        echo "${TEMP_DATA}" |
        grep -Eo '\+[0-9]+\.[0-9]+°C' |
        tr -d '+°C' |
        sort -nr |
        head -1
    )


    [[ -z "${CURRENT_TEMP}" ]] && exit 0


    CURRENT_INT=${CURRENT_TEMP%.*}


    STATE_FILE="${STATE_DIR}/temperature_alert"


    #
    # Critical temperature
    #

    if (( CURRENT_INT >= CRITICAL_TEMP )); then


        if [[ ! -f "${STATE_FILE}" ]]; then

            touch "${STATE_FILE}"

            notify_send \
                "Temperature" \
                "🔥 Critical temperature detected: ${CURRENT_TEMP}°C" || true

        fi


    #
    # Warning temperature
    #

    elif (( CURRENT_INT >= WARNING_TEMP )); then


        if [[ ! -f "${STATE_FILE}" ]]; then

            touch "${STATE_FILE}"

            if [[ "${NOTIFY_ON_WARNING}" == "true" ]]; then

                notify_send \
                    "Temperature" \
                    "⚠️ High temperature detected: ${CURRENT_TEMP}°C" || true

            fi

        fi


    #
    # Recovery
    #

    else


        if [[ -f "${STATE_FILE}" ]]; then

            rm -f "${STATE_FILE}"

            if [[ "${NOTIFY_ON_RECOVERY}" == "true" ]]; then

                notify_send \
                    "Temperature" \
                    "✅ Temperature returned to normal: ${CURRENT_TEMP}°C" || true

            fi

        fi

    fi


) 200>"${LOCK_FILE}"
