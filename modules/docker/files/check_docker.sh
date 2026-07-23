#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Скрипт проверки состояния Docker
# Путь: modules/docker/files/check_docker.sh
# ==============================================================================

set -Eeuo pipefail

LSM_ROOT="${LSM_ROOT:-/opt/lsm}"
CONFIG_FILE="/etc/lsm/modules/docker.conf"
NOTIFY_SCRIPT="${LSM_ROOT}/lib/notifications/notify.sh"

# Параметры по умолчанию
ENABLED=true
CHECK_SERVICE=true
CHECK_CONTAINERS=true
CHECK_STORAGE=true
STOPPED_CONTAINER_WARNING=true
STORAGE_WARNING_GB=50

# Подключение конфигурации
if [[ -f "${CONFIG_FILE}" ]]; then
    # shellcheck source=/dev/null
    source "${CONFIG_FILE}"
fi

# Если модуль отключен — завершаем работу
if [[ "${ENABLED}" != "true" ]]; then
    exit 0
fi

# Флаги режима работы
IS_REPORT_MODE=false
for arg in "$@"; do
    case "${arg}" in
        --report|-r)
            IS_REPORT_MODE=true
            ;;
    esac
done

# Вспомогательная функция отправки уведомлений
send_alert() {
    local severity="$1"
    local message="$2"
    
    if [[ "${IS_REPORT_MODE}" == "false" && -f "${NOTIFY_SCRIPT}" && -x "${NOTIFY_SCRIPT}" ]]; then
        "${NOTIFY_SCRIPT}" "docker" "${severity}" "${message}" || true
    fi
}

# ------------------------------------------------------------------------------
# 1. Проверка наличия Docker
# ------------------------------------------------------------------------------
if ! command -v docker >/dev/null 2>&1; then
    if [[ "${IS_REPORT_MODE}" == "true" ]]; then
        echo "Статус   : ПРЕДУПРЕЖДЕНИЕ"
        echo "Детали   : Docker не установлен в системе"
    else
        echo "[!] WARNING: Docker не установлен в системе"
        send_alert "WARNING" "Docker не установлен в системе"
    fi
    exit 0
fi

docker_version="$(docker version --format '{{.Server.Version}}' 2>/dev/null || echo "Неизвестно")"

# ------------------------------------------------------------------------------
# 2. Проверка службы systemctl docker
# ------------------------------------------------------------------------------
service_active=true
if [[ "${CHECK_SERVICE}" == "true" ]]; then
    if ! systemctl is-active --quiet docker 2>/dev/null; then
        service_active=false
    fi
fi

if [[ "${service_active}" == "false" ]]; then
    if [[ "${IS_REPORT_MODE}" == "true" ]]; then
        echo "Статус   : КРИТИЧЕСКИЙ"
        echo "Версия   : ${docker_version}"
        echo "Ошибка   : Служба Docker остановлена (docker.service inactive)"
    else
        echo "[!] CRITICAL: Служба Docker остановлена"
        send_alert "CRITICAL" "Служба Docker остановлена на сервере"
    fi
    exit 0
fi

# ------------------------------------------------------------------------------
# 3. Сбор статистики контейнеров
# ------------------------------------------------------------------------------
cnt_total=0
cnt_running=0
cnt_stopped=0

if [[ "${CHECK_CONTAINERS}" == "true" ]]; then
    ps_output="$(docker ps -a --format '{{.Status}}' 2>/dev/null || true)"
    if [[ -n "${ps_output}" ]]; then
        cnt_total="$(echo "${ps_output}" | wc -l | tr -d ' ')"
        cnt_running="$(echo "${ps_output}" | grep -c "^Up" || true)"
        cnt_stopped=$(( cnt_total - cnt_running ))
    fi
fi

# ------------------------------------------------------------------------------
# 4. Сбор данных об использовании диска (docker system df)
# ------------------------------------------------------------------------------
img_size="0B"
cnt_size="0B"
vol_size="0B"

if [[ "${CHECK_STORAGE}" == "true" ]]; then
    df_output="$(docker system df 2>/dev/null || true)"
    if [[ -n "${df_output}" ]]; then
        img_size="$(echo "${df_output}" | awk '/Images/ {print $4}' || echo "N/A")"
        cnt_size="$(echo "${df_output}" | awk '/Containers/ {print $4}' || echo "N/A")"
        vol_size="$(echo "${df_output}" | awk '/Local Volumes/ {print $4}' || echo "N/A")"
    fi
fi

# ------------------------------------------------------------------------------
# 5. Вывод отчета / Проверка порогов
# ------------------------------------------------------------------------------
if [[ "${IS_REPORT_MODE}" == "true" ]]; then
    echo "Статус     : OK"
    echo "Версия     : ${docker_version}"
    echo "Контейнеры :"
    echo "  Всего     : ${cnt_total}"
    echo "  Запущены  : ${cnt_running}"
    echo "  Остановлены: ${cnt_stopped}"
    echo "Хранилище  :"
    echo "  Образы    : ${img_size}"
    echo "  Контейнеры: ${cnt_size}"
    echo "  Тома      : ${vol_size}"
else
    # Проверка условий тревоги при штатном мониторинге
    if [[ "${STOPPED_CONTAINER_WARNING}" == "true" && ${cnt_stopped} -gt 0 ]]; then
        echo "[!] WARNING: Обнаружено остановленных контейнеров: ${cnt_stopped}"
        send_alert "WARNING" "Обнаружены остановленные Docker-контейнеры (${cnt_stopped} из ${cnt_total})"
    else
        echo "[+] Docker работает штатно. Запущено контейнеров: ${cnt_running}/${cnt_total}"
    fi
fi
