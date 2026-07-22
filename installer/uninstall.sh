#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Main Uninstaller
# -----------------------------------------------------------------------------

set -Eeuo pipefail

LSM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly LSM_ROOT

#
# Core
#

source "${LSM_ROOT}/lib/core/colors.sh"
source "${LSM_ROOT}/lib/core/logging.sh"
source "${LSM_ROOT}/lib/core/common.sh"
source "${LSM_ROOT}/lib/core/checks.sh"
source "${LSM_ROOT}/lib/core/config.sh"

#
# Installer
#

source "${LSM_ROOT}/lib/installer/deploy.sh"
source "${LSM_ROOT}/lib/installer/services.sh"
source "${LSM_ROOT}/lib/installer/modules.sh"

main() {

    ui_banner

    log_warning "Lite Server Monitor will be removed."

    echo

    read -rp "Continue? [y/N]: " answer

    [[ "${answer}" =~ ^[Yy]$ ]] || exit 0

    #
    # Remove installed modules
    #

    for module in $(modules_list); do

        modules_remove "${module}"

    done

    #
    # Stop services
    #

    if services_exists lsm.service; then

        services_stop_and_disable lsm.service

    fi

    services_daemon_reload

    #
    # Remove directories
    #

    deploy_remove_directory /opt/lsm
    deploy_remove_directory /etc/lsm
    deploy_remove_directory /var/lib/lsm
    deploy_remove_directory /var/log/lsm

    #
    # Remove executable
    #

    deploy_remove_file /usr/local/bin/lsm

    echo

    log_success "Lite Server Monitor has been removed."

}

main "$@"
