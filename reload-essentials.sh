#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
RCON_SENDER="${RCON_SENDER:-$DIR/send-command.sh}"

if [ ! -x "$RCON_SENDER" ]; then
    echo "错误：未找到可执行脚本 $RCON_SENDER" >&2
    exit 1
fi

if "$RCON_SENDER" "essentials:essentials reload" >/dev/null 2>&1; then
    echo "Essentials 已重载（essentials:essentials reload）"
    exit 0
fi

"$RCON_SENDER" "ess reload"
echo "Essentials 已重载（ess reload）"
