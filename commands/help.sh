#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Help Command
# -----------------------------------------------------------------------------

set -Eeuo pipefail

cat <<EOF

Lite Server Monitor (LSM)

Usage:

    lsm <command>

Commands:

    install       Install Lite Server Monitor
    uninstall     Remove Lite Server Monitor
    update        Update Lite Server Monitor

    status        Show current status
    modules       List available modules
    report        Generate health report
    doctor        Diagnose installation
    config        Configure LSM

    version       Show version
    help          Show this help

EOF
