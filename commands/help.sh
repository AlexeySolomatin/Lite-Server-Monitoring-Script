#!/usr/bin/env bash

command_help() {
cat <<EOF
Lite Server Monitor ${PROJECT_VERSION}

Usage:
    lsm <command>

Available commands:

    install        Install Lite Server Monitor
    update         Update Lite Server Monitor
    uninstall      Remove Lite Server Monitor
    doctor         Run diagnostics
    status         Show current status
    report         Generate health report
    version        Show version
    help           Show this help message

Examples:

    lsm install
    lsm doctor
    lsm status
    lsm report
EOF
}
