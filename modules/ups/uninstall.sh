#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# UPS Module Uninstaller
# -----------------------------------------------------------------------------

set -Eeuo pipefail


deploy_remove_file \
    /etc/systemd/system/lsm-ups.service


deploy_remove_file \
    /etc/systemd/system/lsm-ups.timer


deploy_remove_file \
    /etc/lsm/modules/ups.conf


deploy_remove_directory \
    /opt/lsm/modules/ups


log_success "UPS module removed."
