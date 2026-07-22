#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Email Notification
# -----------------------------------------------------------------------------

set -Eeuo pipefail


CONFIG_FILE="${NOTIFICATIONS_FILE:-/etc/lsm/notifications.conf}"

if [[ -f "${CONFIG_FILE}" ]]; then
    # shellcheck source=/dev/null
    source "${CONFIG_FILE}"
fi



TITLE="$1"
MESSAGE="$2"



if [[ -z "${EMAIL_TO:-}" ]]; then
    exit 0
fi


echo "${MESSAGE}" |
mail \
    -s "LSM: ${TITLE}" \
    "${EMAIL_TO}"
