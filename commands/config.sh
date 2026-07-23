#!/usr/bin/env bash
#
# ==============================================================================
# Lite Server Monitor (LSM)
# Команда управления конфигурацией
# ==============================================================================

set -Eeuo pipefail

CONFIG_DIR="/etc/lsm"

# Подключение библиотеки логирования
if [[ -f "${LSM_ROOT:-/opt/lsm}/lib/core/logging.sh" ]]; then
    # shellcheck source=/dev/null
    source "${LSM_ROOT:-/opt/lsm}/lib/core/logging.sh"
fi

log_info "Конфигурационные файлы системы"
log_info "=============================="

find "${CONFIG_DIR}" -type f | sort | while read -r file; do
    log_success "Конфигурационный файл: ${file}"
done
