#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Disk Module Uninstaller
# -----------------------------------------------------------------------------

set -Eeuo pipefail

deploy_remove_file /etc/systemd/system/lsm-disk.service
deploy_remove_file /etc/systemd/system/lsm-disk.timer

deploy_remove_directory /opt/lsm/modules/disk

log_success "Disk module removed."
