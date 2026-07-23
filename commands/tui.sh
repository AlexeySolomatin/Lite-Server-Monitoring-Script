#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Запуск TUI интерфейса
# Путь: commands/tui.sh
# ==============================================================================


set -Eeuo pipefail



LSM_ROOT="${LSM_ROOT:-/opt/lsm}"


#
# Загрузка TUI компонентов
#

load_tui()
{

    local tui_dir="${LSM_ROOT}/lib/tui"


    if [[ ! -d "${tui_dir}" ]]; then

        echo "Ошибка: TUI компоненты не установлены."

        exit 1

    fi


    # shellcheck source=/dev/null
    source "${tui_dir}/core.sh"


    # shellcheck source=/dev/null
    source "${tui_dir}/menu.sh"


    # shellcheck source=/dev/null
    source "${tui_dir}/screens/main.sh"


}



main()
{

    load_tui


    screen_main

}


main "$@"
