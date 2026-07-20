#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# SMART Monitor
# -----------------------------------------------------------------------------

set -Eeuo pipefail

#
# Configuration
#

CONFIG_FILE="/etc/lsm/modules/smart.conf"

[[ -f "${CONFIG_FILE}" ]] && source "${CONFIG_FILE}"

#
# Defaults
#

IGNORE_DEVICES="${IGNORE_DEVICES:-}"
NOTIFY_ON_FAILURE="${NOTIFY_ON_FAILURE:-true}"

#
# Paths
#

STATE_DIR="/var/lib/lsm/state"

LOCK_FILE="${STATE_DIR}/smart_check.lock"

(
    #
    # Prevent parallel execution
    #

    flock -n 200 || exit 0

    #
    # Automatically detect physical disks
    #

    while IFS= read -r DISK; do

        [[ -z "${DISK}" ]] && continue

        #
        # Ignore configured devices
        #

        SKIP=false

        for DEVICE in ${IGNORE_DEVICES}; do

            if [[ "${DISK}" == "${DEVICE}" ]]; then
                SKIP=true
                break
            fi

        done

        [[ "${SKIP}" == true ]] && continue

        DISK_NAME="$(basename "${DISK}")"

        STATE_FILE="${STATE_DIR}/smart_alert_${DISK_NAME}"

        #
        # SMART Health Check
        #

        smartctl -H "${DISK}" >/dev/null 2>&1
        RC=$?

        if (( RC != 0 )); then

            #
            # Failure
            #

            if [[ ! -f "${STATE_FILE}" ]]; then

                touch "${STATE_FILE}"

                if [[ "${NOTIFY_ON_FAILURE}" == "true" ]]; then

                    notify_send \
                        "SMART" \
                        "❌ SMART health check failed for ${DISK}. Immediate disk replacement is recommended." || true

                fi

            fi

        else

            #
            # Recovery
            #

            if [[ -f "${STATE_FILE}" ]]; then

                rm -f "${STATE_FILE}"

                notify_send \
                    "SMART" \
                    "✅ SMART health restored for ${DISK}." || true

            fi

        fi

    done < <(

        find /dev \
            -maxdepth 1 \
            -type b \
            \( \
                -name "sd*" \
                -o -name "nvme*" \
                -o -name "vd*" \
                -o -name "xvd*" \
            \) \
            ! -name "*loop*" \
            ! -name "*ram*" \
            2>/dev/null

    )

) 200>"${LOCK_FILE}"
