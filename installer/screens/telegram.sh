#!/usr/bin/env bash
# shellcheck disable=SC2034
#
# -----------------------------------------------------------------------------
# Lite Server Monitor (LSM)
# Telegram Configuration Screen
# -----------------------------------------------------------------------------

TG_BOT_TOKEN=""
TG_CHAT_ID=""

screen_telegram() {
    wizard_header

    echo "Telegram Configuration"
    echo

    read -rp "Bot Token (from @BotFather): " TG_BOT_TOKEN
    read -rp "Chat ID (or Group ID): " TG_CHAT_ID
}
