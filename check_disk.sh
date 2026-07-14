#!/bin/bash
set -o pipefail

STATE_FILE="/var/lib/print-monitor/state/disk_alert"
LOCK_FILE="/var/lib/print-monitor/state/.disk_check.lock"
MAX_USAGE=80

# Создаём директорию, если её нет
mkdir -p "/var/lib/print-monitor/state"

# Блокировка, чтобы не было параллельных запусков
(
  flock -n 200 || {
    # Если не удалось получить блокировку — выходим
    exit 0
  }

  ALERT_TRIGGERED=0
  ALERT_MSG=""

  # Используем awk для надёжного парсинга df
  while IFS= read -r line; do
    ALERT_TRIGGERED=1
    ALERT_MSG="${ALERT_MSG} ${line}"
  done < <(
    df -P | awk -v max="$MAX_USAGE" '
      NR>1 && $0 !~ /(tmpfs|cdrom|loop)/ {
        gsub(/%/, "", $5);
        if ($5 >= max) printf "%s=%s%%\n", $6, $5
      }'
  )

  if [[ "$ALERT_TRIGGERED" -eq 1 ]]; then
    if [[ ! -f "$STATE_FILE" ]]; then
      touch "$STATE_FILE"
      /usr/local/bin/print_notify.sh "DISK" "❌ Внимание! Зафиксировано критическое заполнение разделов:${ALERT_MSG}" || true
    fi
  else
    if [[ -f "$STATE_FILE" ]]; then
      rm -f "$STATE_FILE"
      /usr/local/bin/print_notify.sh "DISK" "✅ Восстановление! Дисковое пространство вернулось в норму." || true
    fi
  fi

) 200> "$LOCK_FILE"
