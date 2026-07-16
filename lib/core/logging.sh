#!/usr/bin/env bash
#
# Lite Server Monitor (LSM)
# Logging library
#

# shellcheck disable=SC2034

# Default log level:
# 0 = ERROR
# 1 = WARN
# 2 = INFO
# 3 = DEBUG

: "${LOG_LEVEL:=2}"

_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

_log() {
    local level="$1"
    local color="$2"
    local label="$3"
    local message="$4"

    if (( LOG_LEVEL < level )); then
        return
    fi

    printf "%b[%s] %-7s%b %s\n" \
        "${color}" \
        "$(_timestamp)" \
        "${label}" \
        "${COLOR_RESET}" \
        "${message}"
}

log_error() {
    _log 0 "${COLOR_RED}" "ERROR" "$*"
}

log_warn() {
    _log 1 "${COLOR_YELLOW}" "WARN" "$*"
}

log_info() {
    _log 2 "${COLOR_BLUE}" "INFO" "$*"
}

log_success() {
    _log 2 "${COLOR_GREEN}" "OK" "$*"
}

log_debug() {
    _log 3 "${COLOR_MAGENTA}" "DEBUG" "$*"
}
