#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

FORCE_AFTER_WAIT=1
if [[ "${1:-}" == "--graceful-only" ]]; then
    FORCE_AFTER_WAIT=0
    shift
fi

JAR_NAME="${JAR_NAME:-paper-1.21.8-60.jar}"
PID_FILE="${PID_FILE:-$DIR/server.pid}"
WAIT_SECONDS="${WAIT_SECONDS:-75}"
RCON_SENDER="$DIR/send-command.sh"
PROCESS_MATCH="java.*${JAR_NAME//./\\.}"

is_matching_server_pid() {
    local pid="$1"
    [ -n "$pid" ] || return 1
    ps -p "$pid" -o command= 2>/dev/null | grep -Eq "$PROCESS_MATCH"
}

find_pid() {
    if [ -f "$PID_FILE" ]; then
        local stored_pid
        stored_pid=$(cat "$PID_FILE")
        if is_matching_server_pid "$stored_pid"; then
            echo "$stored_pid"
            return
        fi
        rm -f "$PID_FILE"
    fi
    pgrep -f "$PROCESS_MATCH" | head -n 1
}

pid=$(find_pid || true)
if [ -z "${pid:-}" ]; then
    if [ -f "$PID_FILE" ]; then
        rm -f "$PID_FILE"
        echo "未检测到运行中的服务器，已清理旧 PID 文件"
    else
        echo "Minecraft 服务器未运行"
    fi
    exit 0
fi

echo "正在停止 Minecraft 服务器 (PID: $pid)..."

sent_stop=0
if [ -x "$RCON_SENDER" ]; then
    if "$RCON_SENDER" "stop" >/dev/null 2>&1; then
        echo "已通过 RCON 发送 stop 命令"
        sent_stop=1
    else
        echo "RCON 停止命令发送失败，改用信号停止"
    fi
else
    echo "未找到 RCON 发送脚本，改用信号停止"
fi

if [ $sent_stop -eq 0 ]; then
    kill "$pid" >/dev/null 2>&1 || true
fi

for i in $(seq 1 "$WAIT_SECONDS"); do
    if ! ps -p "$pid" >/dev/null 2>&1; then
        echo "服务器已正常停止"
        if [ -f "$PID_FILE" ] && [ "$(cat "$PID_FILE")" = "$pid" ]; then
            rm -f "$PID_FILE"
        fi
        exit 0
    fi
    sleep 1
    if [ $((i % 10)) -eq 0 ]; then
        echo "等待服务器关闭中... (${i}/${WAIT_SECONDS} 秒)"
    fi
done

if [ "$FORCE_AFTER_WAIT" -eq 0 ]; then
    echo "服务器仍在运行，请检查进程或手动处理 (PID: $pid)"
    exit 1
fi

echo "超时未关闭，强制终止进程..."
kill -9 "$pid" >/dev/null 2>&1 || true
sleep 2

if ps -p "$pid" >/dev/null 2>&1; then
    echo "警告：未能强制终止进程 (PID: $pid)"
    exit 1
fi

echo "服务器已强制停止"
if [ -f "$PID_FILE" ] && [ "$(cat "$PID_FILE")" = "$pid" ]; then
    rm -f "$PID_FILE"
fi
