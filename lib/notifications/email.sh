#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Модуль отправки уведомлений по электронной почте (Email)
# Путь: lib/notifications/email.sh
# ==============================================================================

set -Eeuo pipefail

# Загрузка конфигурационного файла уведомлений
CONFIG_FILE="${NOTIFICATIONS_FILE:-/etc/lsm/notifications.conf}"

if [[ -f "${CONFIG_FILE}" ]]; then
    # shellcheck source=/dev/null
    source "${CONFIG_FILE}"
fi

# Безопасное считывание параметров вызова
TITLE="${1:-Уведомление LSM}"
MESSAGE="${2:-}"

# Если получатель не указан — завершаем работу без ошибки
if [[ -z "${EMAIL_TO:-}" ]]; then
    exit 0
fi

# Определение доступной утилиты отправки почты (mail или mailx)
MAIL_CMD=""
if command -v mail >/dev/null 2>&1; then
    MAIL_CMD="mail"
elif command -v mailx >/dev/null 2>&1; then
    MAIL_CMD="mailx"
else
    if declare -f log_error >/dev/null 2>&1; then
        log_error "EMAIL" "Утилита mail/mailx не найдена в системе. Отправка отменена."
    else
        echo "Ошибка: Утилита mail/mailx не найдена в системе." >&2
    fi
    exit 1
fi

if declare -f log_info >/dev/null 2>&1; then
    log_info "EMAIL" "Отправка почтового уведомления на ${EMAIL_TO}..."
fi

# Отправка сообщения
printf '%s\n' "${MESSAGE}" | "${MAIL_CMD}" -s "LSM: ${TITLE}" "${EMAIL_TO}"
