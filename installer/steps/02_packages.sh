#!/usr/bin/env bash

step_packages() {
    log_info "Installing required packages..."

    update_package_cache

    local packages=(
        curl
        wget
        jq
        bc
        msmtp
        smartmontools
        mdadm
        lm-sensors
        fail2ban
    )

    for pkg in "${packages[@]}"; do
        install_package "${pkg}"
    done
}
