#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# SMART Module Uninstaller
# -----------------------------------------------------------------------------

set -Eeuo pipefail

deploy_remove_file /etc/systemd/system/lsm-smart.service

deploy_remove_file /etc/systemd/system/lsm-smart.timer

deploy_remove_file /etc/lsm/modules/smart.conf

deploy_remove_directory /opt/lsm/modules/smart

log_success "SMART module removed."
