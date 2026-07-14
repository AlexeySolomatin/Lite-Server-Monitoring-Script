#!/bin/bash
TOKEN=""
CHAT_ID=""
HOST=$(hostname)
MESSAGE="⚠️ [$HOST]: $1"

curl -s -X POST "https://telegram.org" \
    -d chat_id="$CHAT_ID" \
    -d text="$MESSAGE" \
    -d parse_mode="Markdown" > /dev/null
