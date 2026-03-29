#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
SERVER_DIR="${SERVER_DIR:-$DIR}"
BACKUP_DIR="${BACKUP_DIR:-$SERVER_DIR/backups}"
PID_FILE="${PID_FILE:-$SERVER_DIR/server.pid}"
JAR_NAME="${JAR_NAME:-paper-1.21.8-60.jar}"
PROCESS_MATCH="java.*${JAR_NAME//./\\.}"

is_matching_server_pid() {
    local pid="$1"
    [ -n "$pid" ] || return 1
    ps -p "$pid" -o command= 2>/dev/null | grep -Eq "$PROCESS_MATCH"
}

resolve_realpath() {
    python3 - "$1" <<'PY'
import os, sys
print(os.path.realpath(sys.argv[1]))
PY
}

usage() {
    echo "用法: $0 <备份文件路径|备份文件名>"
    echo "示例: $0 minecraft-backup-20251007-120000.tar.gz"
    echo ""
    echo "可用备份："
    ls -1t "$BACKUP_DIR"/minecraft-backup-*.tar.gz 2>/dev/null | head -n 20 | sed 's#.*/##' || true
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi

if [ -f "$PID_FILE" ]; then
    pid_in_file="$(cat "$PID_FILE" 2>/dev/null || true)"
    if is_matching_server_pid "$pid_in_file"; then
        echo "错误：检测到服务器正在运行，请先停止服务器后再恢复备份" >&2
        exit 1
    fi
    rm -f "$PID_FILE"
fi

if pgrep -f "$PROCESS_MATCH" >/dev/null 2>&1; then
    echo "错误：检测到服务器进程正在运行，请先停止服务器后再恢复备份" >&2
    exit 1
fi

BACKUP_INPUT="$1"
if [ -f "$BACKUP_INPUT" ]; then
    BACKUP_PATH="$BACKUP_INPUT"
elif [ -f "$BACKUP_DIR/$BACKUP_INPUT" ]; then
    BACKUP_PATH="$BACKUP_DIR/$BACKUP_INPUT"
else
    echo "错误：备份文件不存在：$BACKUP_INPUT" >&2
    usage
    exit 1
fi

BACKUP_DIR_REAL=$(resolve_realpath "$BACKUP_DIR")
BACKUP_PATH_REAL=$(resolve_realpath "$BACKUP_PATH")
if [[ "$BACKUP_PATH_REAL" != "$BACKUP_DIR_REAL/"* ]]; then
    echo "错误：备份文件必须位于 $BACKUP_DIR" >&2
    exit 1
fi

if [[ "$BACKUP_PATH" != *.tar.gz ]]; then
    echo "错误：备份文件必须以 .tar.gz 结尾" >&2
    exit 1
fi

if tar -tzf "$BACKUP_PATH" | grep -Eq '(^/|(^|/)\.\.(/|$))'; then
    echo "错误：备份文件包含不安全的路径，已拒绝恢复" >&2
    exit 1
fi

echo "准备恢复备份到: $SERVER_DIR"
echo "备份文件: $BACKUP_PATH"
echo "输入 YES 继续恢复（会覆盖同名文件）："
read -r confirm
if [ "$confirm" != "YES" ]; then
    echo "已取消"
    exit 1
fi

tar -xzf "$BACKUP_PATH" -C "$SERVER_DIR"
echo "恢复完成"
