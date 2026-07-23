#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# TUI Loader
# Путь: lib/tui/tui.sh
# ==============================================================================


set -Eeuo pipefail


LSM_TUI_DIR="${LSM_ROOT}/lib/tui"



source "${LSM_TUI_DIR}/dialog.sh"


source "${LSM_TUI_DIR}/screens/main.sh"
source "${LSM_TUI_DIR}/screens/modules.sh"
source "${LSM_TUI_DIR}/screens/install.sh"
source "${LSM_TUI_DIR}/screens/config.sh"
source "${LSM_TUI_DIR}/screens/report.sh"
source "${LSM_TUI_DIR}/screens/doctor.sh"



tui_start()
{

    tui_check || exit 1

    screen_main

}
