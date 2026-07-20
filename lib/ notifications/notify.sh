#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Notification Dispatcher
# -----------------------------------------------------------------------------

set -Eeuo pipefail


CONFIG_FILE="/etc/lsm/config"


#
# Load configuration
#

[[ -f "${CONFIG_FILE}" ]] &&
    source "${CONFIG_FILE}"


#
# Notification modules
#

NOTIFY_TELEGRAM="${NOTIFY_TELEGRAM:-false}"
NOTIFY_EMAIL="${NOTIFY_EMAIL:-false}"


#
# Paths
#

LSM_LIB="/opt/lsm/lib/notifications"



notify_send()
{

    local TITLE="$1"
    local MESSAGE="$2"


    #
    # Telegram
    #

    if [[ "${NOTIFY_TELEGRAM}" == "true" ]]; then

        "${LSM_LIB}/telegram.sh" \
            "${TITLE}" \
            "${MESSAGE}" || true

    fi



    #
    # Email
    #

    if [[ "${NOTIFY_EMAIL}" == "true" ]]; then

        "${LSM_LIB}/email.sh" \
            "${TITLE}" \
            "${MESSAGE}" || true

    fi


}
