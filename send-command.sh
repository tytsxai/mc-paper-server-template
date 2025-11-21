#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
SERVER_PROPERTIES="${SERVER_PROPERTIES:-$DIR/server.properties}"
PY_CLIENT="$DIR/scripts/rcon-send.py"

read_prop() {
    local key="$1"
    if [ -f "$SERVER_PROPERTIES" ]; then
        grep -E "^[[:space:]]*${key}=" "$SERVER_PROPERTIES" | tail -n 1 | cut -d'=' -f2-
    fi
}

if [ $# -lt 1 ]; then
    echo "用法: $0 <要发送的命令>" >&2
    exit 1
fi

HOST="${RCON_HOST:-localhost}"
PORT="${RCON_PORT:-$(read_prop "rcon.port")}"
PASSWORD="${RCON_PASSWORD:-$(read_prop "rcon.password")}"
ENABLED="${RCON_ENABLED:-$(read_prop "enable-rcon")}"
CMD="$*"

if [ "${ENABLED,,}" != "true" ]; then
    echo "RCON 未启用 (enable-rcon=false)，无法发送命令" >&2
    exit 1
fi

if [ -z "${PORT:-}" ]; then
    PORT=25575
fi

if [ -z "${PASSWORD:-}" ]; then
    echo "未在 server.properties 中找到 rcon.password" >&2
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "缺少 python3，无法发送 RCON 命令" >&2
    exit 1
fi

if [ ! -f "$PY_CLIENT" ]; then
    echo "缺少 RCON 客户端脚本：$PY_CLIENT" >&2
    exit 1
fi

python3 "$PY_CLIENT" "$HOST" "$PORT" "$PASSWORD" "$CMD"
