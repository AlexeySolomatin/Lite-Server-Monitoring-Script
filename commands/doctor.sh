#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Doctor Command
# -----------------------------------------------------------------------------

set -Eeuo pipefail

echo
echo "Lite Server Monitor Diagnostic"
echo "=============================="
echo

#
# Root
#

if [[ $EUID -eq 0 ]]; then
    log_success "Running as root"
else
    log_error "Run as root"
fi

#
# Directories
#

check_dir() {

    local dir="$1"

    if [[ -d "${dir}" ]]; then
        log_success "${dir}"
    else
        log_error "${dir}"
    fi

}

echo
echo "Directories"

check_dir /etc/lsm
check_dir /opt/lsm
check_dir /var/lib/lsm
check_dir /var/log/lsm

#
# Services
#

echo
echo "Services"

systemctl list-unit-files | grep "^lsm-" || true

#
# Timers
#

echo
echo "Timers"

systemctl list-timers --all | grep "^lsm-" || true

#
# Disk space
#

echo
echo "Filesystem"

df -h /

echo
