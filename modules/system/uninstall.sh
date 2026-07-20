#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# System Module Uninstaller
# -----------------------------------------------------------------------------

set -Eeuo pipefail


deploy_remove_file \
    /etc/systemd/system/lsm-system.service


deploy_remove_file \
    /etc/systemd/system/lsm-system.timer


deploy_remove_file \
    /etc/lsm/modules/system.conf


deploy_remove_directory \
    /opt/lsm/modules/system


log_success "System module removed."
