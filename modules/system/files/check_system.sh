#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# System Monitor
# -----------------------------------------------------------------------------

set -Eeuo pipefail


#
# Configuration
#

CONFIG_FILE="/etc/lsm/modules/system.conf"

if [[ -f "${CONFIG_FILE}" ]]; then
    # shellcheck source=/dev/null
    source "${CONFIG_FILE}"
fi


#
# Defaults
#

LOAD_WARNING="${LOAD_WARNING:-5.0}"
LOAD_CRITICAL="${LOAD_CRITICAL:-10.0}"

MEMORY_WARNING="${MEMORY_WARNING:-85}"
MEMORY_CRITICAL="${MEMORY_CRITICAL:-95}"

DISK_WARNING="${DISK_WARNING:-85}"
DISK_CRITICAL="${DISK_CRITICAL:-95}"

NOTIFY_ON_WARNING="${NOTIFY_ON_WARNING:-true}"
NOTIFY_ON_RECOVERY="${NOTIFY_ON_RECOVERY:-true}"


#
# Paths
#

STATE_DIR="/var/lib/lsm/state"

STATUS_FILE="${STATE_DIR}/system.status"

ALERT_FILE="${STATE_DIR}/system_alert"

LOCK_FILE="${STATE_DIR}/system_check.lock"



(
    #
    # Prevent parallel execution
    #

    flock -n 200 || exit 0


    STATUS="OK"

    ALERT_MESSAGE=""


    #
    # CPU Load
    #

    LOAD=$(awk '{print $1}' /proc/loadavg)

    LOAD_INT=${LOAD%.*}


    if (( LOAD_INT >= ${LOAD_CRITICAL%.*} )); then

        STATUS="CRITICAL"

        ALERT_MESSAGE+=" Load critical: ${LOAD}"

    elif (( LOAD_INT >= ${LOAD_WARNING%.*} )); then

        [[ "${STATUS}" != "CRITICAL" ]] &&
            STATUS="WARNING"

        ALERT_MESSAGE+=" Load high: ${LOAD}"

    fi



    #
    # Memory
    #

    MEMORY_USED=$(

        free | awk '/Mem:/ {

            printf "%.0f", $3/$2*100

        }'

    )


    if (( MEMORY_USED >= MEMORY_CRITICAL )); then

        STATUS="CRITICAL"

        ALERT_MESSAGE+=" Memory critical: ${MEMORY_USED}%"

    elif (( MEMORY_USED >= MEMORY_WARNING )); then

        [[ "${STATUS}" != "CRITICAL" ]] &&
            STATUS="WARNING"

        ALERT_MESSAGE+=" Memory high: ${MEMORY_USED}%"

    fi



    #
    # Root filesystem
    #

    DISK_USED=$(

        df -P / |
        awk 'NR==2 {print $5}' |
        tr -d %

    )


    if (( DISK_USED >= DISK_CRITICAL )); then

        STATUS="CRITICAL"

        ALERT_MESSAGE+=" Disk critical: ${DISK_USED}%"

    elif (( DISK_USED >= DISK_WARNING )); then

        [[ "${STATUS}" != "CRITICAL" ]] &&
            STATUS="WARNING"

        ALERT_MESSAGE+=" Disk high: ${DISK_USED}%"

    fi



    #
    # Save current status
    #

    cat > "${STATUS_FILE}" <<EOF
STATUS=${STATUS}
LOAD=${LOAD}
MEMORY=${MEMORY_USED}
DISK=${DISK_USED}
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
EOF



    #
    # Notifications
    #

    if [[ "${STATUS}" != "OK" ]]; then


        if [[ ! -f "${ALERT_FILE}" ]]; then


            touch "${ALERT_FILE}"


            if [[ "${NOTIFY_ON_WARNING}" == "true" ]]; then


                notify_send \
                    "System" \
                    "⚠️ System health warning:${ALERT_MESSAGE}" || true


            fi


        fi



    else


        if [[ -f "${ALERT_FILE}" ]]; then


            rm -f "${ALERT_FILE}"


            if [[ "${NOTIFY_ON_RECOVERY}" == "true" ]]; then


                notify_send \
                    "System" \
                    "✅ System health returned to normal." || true


            fi


        fi


    fi


) 200>"${LOCK_FILE}"
