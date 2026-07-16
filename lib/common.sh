# Версия проекта
PROJECT_NAME="Lite Server Monitor"
PROJECT_SHORT_NAME="LSM"
PROJECT_VERSION="0.1.0-alpha"

# Основные каталоги
INSTALL_DIR="/opt/lsm"
CONFIG_DIR="/etc/lsm"
STATE_DIR="/var/lib/lsm"
LOG_DIR="/var/log/lsm"
RUN_DIR="/run/lsm"
BIN_DIR="/usr/local/bin"

# Подключение библиотек
source colors.sh
source logging.sh
source checks.sh
source filesystem.sh
source config.sh
source ui.sh
source utils.sh
