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

if ! command -v "$JAVA_BIN" >/dev/null 2>&1; then
    echo "错误：未找到 Java 可执行文件，请确认已安装 Java 21+"
    exit 1
fi

if [ ! -f "$JAR_NAME" ]; then
    echo "错误：未找到服务器核心 $JAR_NAME"
    exit 1
fi

if [ -f "$PID_FILE" ]; then
    PID_CONTENT=$(cat "$PID_FILE")
    if [ -n "$PID_CONTENT" ] && ps -p "$PID_CONTENT" >/dev/null 2>&1; then
        echo "错误：Minecraft 服务器已经在运行 (PID: $PID_CONTENT)"
        echo "如果这是旧的 PID，请删除 $PID_FILE 后重试"
        exit 1
    fi
fi

if pgrep -f "$PROCESS_MATCH" >/dev/null 2>&1; then
    echo "错误：检测到已有 Minecraft 服务器进程在运行"
    echo "如需重新启动，请先执行 ./stop-graceful.sh 或 ./stop.sh"
    exit 1
fi

nohup "$JAVA_BIN" $JAVA_OPTS -jar "$JAR_NAME" nogui > "$LOG_FILE" 2>&1 &
PID=$!
echo "$PID" > "$PID_FILE"

echo "Minecraft 服务器正在后台启动 (PID: $PID)"
echo "日志文件: $LOG_FILE"
echo "平滑停止: ./stop-graceful.sh    强制停止: ./stop.sh"
