#!/usr/bin/env bash

command_help() {

cat <<EOF
Lite Server Monitor ${PROJECT_VERSION}

Usage:

    lsm <command>

Commands:

    install        Install Lite Server Monitor
    update         Update Lite Server Monitor
    uninstall      Remove Lite Server Monitor

    doctor         Run diagnostics
    status         Show current status
    report         Generate health report

    config         Configuration management
    modules        Module management

    version        Show version
    help           Show this help

Examples:

    lsm install
    lsm doctor
    lsm status
    lsm modules
    lsm config

EOF

}
