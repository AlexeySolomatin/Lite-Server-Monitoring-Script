#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Main Installer
# -----------------------------------------------------------------------------

set -Eeuo pipefail

LSM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly LSM_ROOT

# -----------------------------------------------------------------------------
# Core Libraries
# -----------------------------------------------------------------------------

source "${LSM_ROOT}/lib/core/colors.sh"
source "${LSM_ROOT}/lib/core/logging.sh"
source "${LSM_ROOT}/lib/core/common.sh"
source "${LSM_ROOT}/lib/core/checks.sh"
source "${LSM_ROOT}/lib/core/config.sh"
source "${LSM_ROOT}/lib/core/filesystem.sh"
source "${LSM_ROOT}/lib/core/ui.sh"
source "${LSM_ROOT}/lib/core/utils.sh"

# -----------------------------------------------------------------------------
# Installer Libraries
# -----------------------------------------------------------------------------

source "${LSM_ROOT}/lib/installer/packages.sh"
source "${LSM_ROOT}/lib/installer/deploy.sh"
source "${LSM_ROOT}/lib/installer/services.sh"
source "${LSM_ROOT}/lib/installer/permissions.sh"
source "${LSM_ROOT}/lib/installer/modules.sh"

# -----------------------------------------------------------------------------
# Wizard
# -----------------------------------------------------------------------------

source "${LSM_ROOT}/installer/wizard.sh"

# -----------------------------------------------------------------------------
# Installation Steps
# -----------------------------------------------------------------------------

source "${LSM_ROOT}/installer/steps/01_environment.sh"
source "${LSM_ROOT}/installer/steps/02_packages.sh"
source "${LSM_ROOT}/installer/steps/03_directories.sh"
source "${LSM_ROOT}/installer/steps/04_configuration.sh"
source "${LSM_ROOT}/installer/steps/05_modules.sh"
source "${LSM_ROOT}/installer/steps/06_services.sh"
source "${LSM_ROOT}/installer/steps/07_permissions.sh"
source "${LSM_ROOT}/installer/steps/08_finish.sh"

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {

    ui_banner

    step_environment

    run_install_wizard

    step_packages
    step_directories
    step_configuration
    step_modules
    step_services
    step_permissions
    step_finish

}

main "$@"
