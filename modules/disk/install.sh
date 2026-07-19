#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Disk Module Installer
# -----------------------------------------------------------------------------

set -Eeuo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_info "Installing Disk module..."

deploy_create_directory "/opt/lsm/modules/disk"

deploy_install_file \
    "${MODULE_DIR}/files/check_disk.sh" \
    "/opt/lsm/modules/disk/check_disk.sh" \
    755

deploy_install_file \
    "${MODULE_DIR}/files/lsm-disk.service" \
    "/etc/systemd/system/lsm-disk.service"

deploy_install_file \
    "${MODULE_DIR}/files/lsm-disk.timer" \
    "/etc/systemd/system/lsm-disk.timer"

log_success "Disk module installed."
