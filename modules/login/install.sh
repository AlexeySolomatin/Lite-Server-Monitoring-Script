#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Login Module Installer
# -----------------------------------------------------------------------------

set -Eeuo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


log_info "Installing Login module..."


deploy_create_directory \
    "/opt/lsm/modules/login"


deploy_install_file \
    "${MODULE_DIR}/files/check_login.sh" \
    "/opt/lsm/modules/login/check_login.sh" \
    755


deploy_install_file \
    "${MODULE_DIR}/files/lsm-login.service" \
    "/etc/systemd/system/lsm-login.service"


deploy_install_file \
    "${MODULE_DIR}/files/lsm-login.timer" \
    "/etc/systemd/system/lsm-login.timer"


templates_install \
    "modules/login.conf" \
    "/etc/lsm/modules/login.conf"


log_success "Login module installed."
