#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# System Module Installer
# -----------------------------------------------------------------------------

set -Eeuo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_info "Installing System module..."


deploy_create_directory \
    "/opt/lsm/modules/system"


deploy_install_file \
    "${MODULE_DIR}/files/check_system.sh" \
    "/opt/lsm/modules/system/check_system.sh" \
    755


deploy_install_file \
    "${MODULE_DIR}/files/lsm-system.service" \
    "/etc/systemd/system/lsm-system.service"


deploy_install_file \
    "${MODULE_DIR}/files/lsm-system.timer" \
    "/etc/systemd/system/lsm-system.timer"


templates_install \
    "modules/system.conf" \
    "/etc/lsm/modules/system.conf"


log_success "System module installed."
