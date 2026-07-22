#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# RAID Monitor
# -----------------------------------------------------------------------------

set -Eeuo pipefail

#
# Configuration
#

CONFIG_FILE="/etc/lsm/modules/raid.conf"

if [[ -f "${CONFIG_FILE}" ]]; then
    # shellcheck source=/dev/null
    source "${CONFIG_FILE}"
fi

#
# Defaults
#

NOTIFY_ON_FAILURE="${NOTIFY_ON_FAILURE:-true}"
NOTIFY_ON_RECOVERY="${NOTIFY_ON_RECOVERY:-true}"
IGNORE_ARRAYS="${IGNORE_ARRAYS:-}"

#
# Paths
#

STATE_DIR="/var/lib/lsm/state"

STATE_FILE="${STATE_DIR}/raid_alert"

LOCK_FILE="${STATE_DIR}/raid_check.lock"

(
    #
    # Prevent parallel execution
    #

    flock -n 200 || exit 0

    ALERT_TRIGGERED=0
    ALERT_MSG=""

    #
    # Check every mdadm array
    #

    while IFS= read -r MD_NAME; do

        [[ -z "${MD_NAME}" ]] && continue

        MD_DEVICE="/dev/${MD_NAME}"

        #
        # Ignore configured arrays
        #

        SKIP=false

        for ARRAY in ${IGNORE_ARRAYS}; do
            if [[ "${MD_DEVICE}" == "${ARRAY}" ]]; then
                SKIP=true
                break
            fi
        done

        [[ "${SKIP}" == true ]] && continue

        if mdadm --detail "${MD_DEVICE}" 2>/dev/null |
            grep -i "State :" |
            grep -qE "degraded|failed"; then

            ALERT_TRIGGERED=1

            STATUS_LINE="$(
                mdadm --detail "${MD_DEVICE}" 2>/dev/null |
                grep -i "State :"
            )"

            ALERT_MSG="${ALERT_MSG} ${MD_DEVICE}: $(echo "${STATUS_LINE}" | xargs)"

        fi

    done < <(

        awk '/^md/ {print $1}' /proc/mdstat 2>/dev/null

    )

    #
    # Alert
    #

    if (( ALERT_TRIGGERED == 1 )); then

        if [[ ! -f "${STATE_FILE}" ]]; then

            touch "${STATE_FILE}"

            if [[ "${NOTIFY_ON_FAILURE}" == "true" ]]; then

                notify_send \
                    "RAID" \
                    "❌ RAID array degraded:${ALERT_MSG}" || true

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
                    "RAID" \
                    "✅ RAID arrays are healthy again." || true

            fi

        fi

    fi

) 200>"${LOCK_FILE}"
