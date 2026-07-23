#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Модуль: core (Удаление таймера и сервиса отчетов)
# Путь: modules/core/uninstall.sh
# ==============================================================================

set -Eeuo pipefail

SYSTEMD_DIR="/etc/systemd/system"

echo "[i] Остановка и удаление системных юнитов отчетов LSM..."

systemctl stop lsm-report.timer 2>/dev/null || true
systemctl disable lsm-report.timer 2>/dev/null || true

rm -f "${SYSTEMD_DIR}/lsm-report.service"
rm -f "${SYSTEMD_DIR}/lsm-report.timer"

systemctl daemon-reload

echo "[+] Юниты lsm-report успешно удалены."
