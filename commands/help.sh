#!/usr/bin/env bash
# ==============================================================================
# Lite Server Monitor (LSM)
# Справка команд CLI
# Путь: commands/help.sh
# ==============================================================================


set -Eeuo pipefail



cat <<EOF


Lite Server Monitor (LSM)

Система мониторинга Linux серверов


Использование:

  lsm <команда>



Основные команды:


  install

      Установка LSM



  uninstall

      Удаление LSM



  update

      Обновление компонентов



  status

      Текущее состояние системы



  doctor

      Диагностика установки



  report

      Формирование отчетов



  config

      Управление конфигурацией



  modules

      Управление модулями



  version

      Версия системы



Управление модулями:


  lsm modules list

      Установленные модули


  lsm modules available

      Все доступные модули


  lsm modules info <module>

      Информация о модуле


  lsm modules install <module>

      Установка модуля


  lsm modules remove <module>

      Удаление модуля



Пример:


  lsm modules info smart


EOF
