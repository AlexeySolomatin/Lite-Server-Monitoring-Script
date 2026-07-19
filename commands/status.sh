#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Status Command
# -----------------------------------------------------------------------------

set -Eeuo pipefail

echo
echo "Lite Server Monitor"
echo "==================="
echo

echo "Version : $(cat /opt/lsm/VERSION 2>/dev/null || echo "Development")"
echo

echo "Installed Modules:"
echo

for dir in /opt/lsm/modules/*; do

    [[ -d "${dir}" ]] || continue

    printf "  • %s\n" "$(basename "${dir}")"

done

echo

echo "Systemd Timers:"
echo

systemctl list-timers --all | grep "^lsm-" || true

echo

echo "Systemd Services:"
echo

systemctl --no-pager --type=service | grep "lsm-" || true

echo
