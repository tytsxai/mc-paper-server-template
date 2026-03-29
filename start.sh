#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

JAR_NAME="${JAR_NAME:-paper-1.21.8-60.jar}"
JAVA_BIN="${JAVA_BIN:-${JAVA_HOME:+$JAVA_HOME/bin/java}}"
JAVA_BIN="${JAVA_BIN:-java}"
JAVA_OPTS="${JAVA_OPTS:--Xms4G -Xmx10G}"
LOG_FILE="${LOG_FILE:-$DIR/server.log}"
PID_FILE="${PID_FILE:-$DIR/server.pid}"
PROCESS_MATCH="java.*${JAR_NAME//./\\.}"
SERVER_PROPERTIES="${SERVER_PROPERTIES:-$DIR/server.properties}"

is_matching_server_pid() {
    local pid="$1"
    [ -n "$pid" ] || return 1
    ps -p "$pid" -o command= 2>/dev/null | grep -Eq "$PROCESS_MATCH"
}

read_server_prop() {
    local key="$1"
    if [ -f "$SERVER_PROPERTIES" ]; then
        grep -E "^[[:space:]]*${key}=" "$SERVER_PROPERTIES" | tail -n 1 | cut -d'=' -f2-
    fi
}

if ! command -v "$JAVA_BIN" >/dev/null 2>&1; then
    echo "错误：未找到 Java 可执行文件，请确认已安装 Java 21+"
    exit 1
fi

if [ ! -f "$JAR_NAME" ]; then
    echo "错误：未找到服务器核心 $JAR_NAME"
    exit 1
fi

RCON_ENABLED_RAW="$(read_server_prop "enable-rcon")"
RCON_PASSWORD_RAW="$(read_server_prop "rcon.password")"
RCON_ENABLED="${RCON_ENABLED_RAW,,}"
if [ "$RCON_ENABLED" = "true" ]; then
    if [ -z "$RCON_PASSWORD_RAW" ]; then
        echo "警告：RCON 已启用但未配置密码，请立即修复 server.properties"
    elif [ "${#RCON_PASSWORD_RAW}" -lt 12 ] || [ "$RCON_PASSWORD_RAW" = "your_secure_password_here" ]; then
        echo "警告：当前 RCON 密码强度过低，建议立即更换为 12 位以上随机密码并限制端口访问"
    fi
fi

if [ -f "$PID_FILE" ]; then
    PID_CONTENT=$(cat "$PID_FILE")
    if is_matching_server_pid "$PID_CONTENT"; then
        echo "错误：Minecraft 服务器已经在运行 (PID: $PID_CONTENT)"
        exit 1
    fi
    rm -f "$PID_FILE"
fi

if pgrep -f "$PROCESS_MATCH" >/dev/null 2>&1; then
    echo "错误：检测到已有 Minecraft 服务器进程在运行"
    echo "如需重新启动，请先执行 ./stop-graceful.sh 或 ./stop.sh"
    exit 1
fi

nohup "$JAVA_BIN" $JAVA_OPTS -jar "$JAR_NAME" nogui > "$LOG_FILE" 2>&1 &
PID=$!
echo "$PID" > "$PID_FILE"

sleep 2
if ! ps -p "$PID" >/dev/null 2>&1; then
    echo "错误：服务器进程启动失败，请检查日志文件"
    rm -f "$PID_FILE"
    echo "日志文件: $LOG_FILE"
    exit 1
fi

echo "Minecraft 服务器正在后台启动 (PID: $PID)"
echo "日志文件: $LOG_FILE"
echo "平滑停止: ./stop-graceful.sh    强制停止: ./stop.sh"
