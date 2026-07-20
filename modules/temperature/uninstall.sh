#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Temperature Module Uninstaller
# -----------------------------------------------------------------------------

set -Eeuo pipefail

deploy_remove_file /etc/systemd/system/lsm-temperature.service
deploy_remove_file /etc/systemd/system/lsm-temperature.timer
deploy_remove_file /etc/lsm/modules/temperature.conf
deploy_remove_directory /opt/lsm/modules/temperature

log_success "Temperature module removed."
