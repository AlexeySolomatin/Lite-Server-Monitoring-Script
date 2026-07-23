#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Модуль: core (Установка таймера и сервиса отчетов)
# Путь: modules/core/install.sh
# ==============================================================================

set -Eeuo pipefail

LSM_ROOT="${LSM_ROOT:-/opt/lsm}"
SYSTEMD_DIR="/etc/systemd/system"
FILES_DIR="${LSM_ROOT}/modules/core/files"

# Подключение базовой библиотеки, если доступна
if [[ -f "${LSM_ROOT}/lib/core/common.sh" ]]; then
    # shellcheck source=/dev/null
    source "${LSM_ROOT}/lib/core/common.sh"
fi

echo "[i] Установка системных юнитов ежедневных отчетов LSM..."

if [[ -d "${FILES_DIR}" ]]; then
    cp "${FILES_DIR}/lsm-report.service" "${SYSTEMD_DIR}/"
    cp "${FILES_DIR}/lsm-report.timer" "${SYSTEMD_DIR}/"
    
    chmod 644 "${SYSTEMD_DIR}/lsm-report.service" "${SYSTEMD_DIR}/lsm-report.timer"
    
    systemctl daemon-reload
    systemctl enable lsm-report.timer
    systemctl restart lsm-report.timer
    
    if declare -f log_success >/dev/null 2>&1; then
        log_success "Таймер lsm-report.timer успешно активирован."
    else
        echo "[+] Таймер lsm-report.timer успешно активирован."
    fi
else
    echo "[!] Ошибка: Директория с файлами не найдена по пути ${FILES_DIR}" >&2
    exit 1
fi
