#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
RCON_SENDER="${RCON_SENDER:-$DIR/send-command.sh}"
STARTUP_WAIT_SECONDS="${STARTUP_WAIT_SECONDS:-10}"

if [ ! -x "$RCON_SENDER" ]; then
    echo "错误：未找到可执行的 RCON 发送脚本：$RCON_SENDER" >&2
    exit 1
fi

send_cmd() {
    local cmd="$1"
    if "$RCON_SENDER" "$cmd" >/dev/null 2>&1; then
        echo "已执行: $cmd"
    else
        echo "执行失败: $cmd" >&2
        exit 1
    fi
}

echo "等待服务器启动（${STARTUP_WAIT_SECONDS}s）..."
sleep "$STARTUP_WAIT_SECONDS"

echo "设置游戏规则..."
send_cmd "gamerule mobGriefing true"
send_cmd "difficulty hard"

echo "当前游戏规则："
"$RCON_SENDER" "gamerule mobGriefing" || true
"$RCON_SENDER" "difficulty" || true

echo "游戏规则设置完成"
