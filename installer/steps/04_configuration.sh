#!/usr/bin/env bash

step_configuration() {
    log_info "Installing default configuration..."

    deploy_install_file \
        "${LSM_ROOT}/templates/config.conf" \
        "/etc/lsm/config.conf" \
        640
}
