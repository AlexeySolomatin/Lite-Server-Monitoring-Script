#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Report Command
# -----------------------------------------------------------------------------

set -Eeuo pipefail

echo
echo "Lite Server Monitor Report"
echo "=========================="
echo

echo "Hostname : $(hostname)"
echo "Kernel   : $(uname -r)"
echo

echo "Uptime"

uptime

echo

echo "Memory"

free -h

echo

echo "Filesystem"

df -h

echo

echo "Load"

cat /proc/loadavg

echo
