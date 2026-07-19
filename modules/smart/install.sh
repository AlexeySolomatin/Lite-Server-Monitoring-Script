#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# SMART Module Installer
# -----------------------------------------------------------------------------

set -Eeuo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_info "Installing SMART module..."

deploy_create_directory "/opt/lsm/modules/smart"

deploy_install_file \
    "${MODULE_DIR}/files/check_smart.sh" \
    "/opt/lsm/modules/smart/check_smart.sh" \
    755

deploy_install_file \
    "${MODULE_DIR}/files/lsm-smart.service" \
    "/etc/systemd/system/lsm-smart.service"

deploy_install_file \
    "${MODULE_DIR}/files/lsm-smart.timer" \
    "/etc/systemd/system/lsm-smart.timer"

templates_install \
    "modules/smart.conf" \
    "/etc/lsm/modules/smart.conf"

log_success "SMART module installed."
