#!/usr/bin/env bash

set -euo pipefail

# Minecraft 服务器自动备份和 GitHub 推送脚本
# 作者: AI Assistant
# 日期: 2025-10-06

# ===== 配置部分 =====
DIR="$(cd "$(dirname "$0")" && pwd)"
SERVER_DIR="${SERVER_DIR:-$DIR}"
BACKUP_DIR="${BACKUP_DIR:-$SERVER_DIR/backups}"
LOG_FILE="${LOG_FILE:-$SERVER_DIR/backup-push.log}"
MAX_BACKUPS=7  # 保留最近7个本地备份
MAX_LOG_LINES=1000  # 日志文件最大行数
PID_FILE="${PID_FILE:-$SERVER_DIR/server.pid}"
SEND_COMMAND_SCRIPT="${SEND_COMMAND_SCRIPT:-$SERVER_DIR/send-command.sh}"
JAR_NAME="${JAR_NAME:-paper-1.21.8-60.jar}"
PROCESS_MATCH="java.*${JAR_NAME//./\\.}"
SERVER_RUNNING=false
AUTOSAVE_DISABLED=false

is_matching_server_pid() {
    local pid="$1"
    [ -n "$pid" ] || return 1
    ps -p "$pid" -o command= 2>/dev/null | grep -Eq "$PROCESS_MATCH"
}

run_and_log() {
    local tmp_file
    local status

    tmp_file=$(mktemp)
    if "$@" >"$tmp_file" 2>&1; then
        status=0
    else
        status=$?
    fi

    while IFS= read -r line; do
        [ -n "$line" ] && log "  $line"
    done < "$tmp_file"
    rm -f "$tmp_file"

    return "$status"
}

# ===== 日志函数 =====
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
    
    # 限制日志文件大小
    if [ -f "$LOG_FILE" ]; then
        local line_count=$(wc -l < "$LOG_FILE")
        if [ "$line_count" -gt "$MAX_LOG_LINES" ]; then
            tail -n "$MAX_LOG_LINES" "$LOG_FILE" > "$LOG_FILE.tmp"
            mv "$LOG_FILE.tmp" "$LOG_FILE"
        fi
    fi
}

# ===== 错误处理 =====
error_exit() {
    restore_autosave_if_needed
    log "错误: $1"
    exit 1
}

is_server_running() {
    if [ -f "$PID_FILE" ]; then
        local pid
        pid=$(cat "$PID_FILE" 2>/dev/null || true)
        if is_matching_server_pid "$pid"; then
            return 0
        fi
        rm -f "$PID_FILE"
    fi
    pgrep -f "$PROCESS_MATCH" >/dev/null 2>&1
}

build_tar_excludes() {
    local server_real backup_real rel_path
    server_real=$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$SERVER_DIR")
    backup_real=$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$BACKUP_DIR")

    TAR_EXCLUDES=(
        --exclude='*.log'
        --exclude='logs/*'
        --exclude='cache/*'
        --exclude='.git/*'
        --exclude='*.jar.old'
        --exclude='backup-push.log'
        --exclude='server.pid'
    )

    if [[ "$backup_real" == "$server_real"/* ]]; then
        rel_path="${backup_real#$server_real/}"
        TAR_EXCLUDES+=("--exclude=./$rel_path" "--exclude=./$rel_path/*")
    fi
}

send_server_command() {
    local command="$1"
    if [ -x "$SEND_COMMAND_SCRIPT" ] && "$SEND_COMMAND_SCRIPT" "$command" >/dev/null 2>&1; then
        return 0
    fi
    if command -v screen >/dev/null 2>&1; then
        local screen_name="minecraft"
        if screen -list | grep -q "$screen_name"; then
            screen -S "$screen_name" -p 0 -X stuff "$command$(printf \\r)"
            return 0
        fi
    fi
    return 1
}

restore_autosave_if_needed() {
    if [ "$SERVER_RUNNING" = true ] && [ "$AUTOSAVE_DISABLED" = true ]; then
        if send_server_command "save-on"; then
            AUTOSAVE_DISABLED=false
            log "已恢复服务器自动保存"
        else
            log "警告: 恢复自动保存失败，请手动执行 save-on"
        fi
    fi
}

# ===== 开始备份流程 =====
log "========== 开始备份流程 =========="

# 1. 创建备份目录
mkdir -p "$BACKUP_DIR" || error_exit "无法创建备份目录"
build_tar_excludes

# 2. 生成备份文件名
BACKUP_NAME="minecraft-backup-$(date '+%Y%m%d-%H%M%S').tar.gz"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

# 3. 检查服务器是否正在运行
if is_server_running; then
    log "检测到服务器正在运行，发送保存命令..."

    if ! send_server_command "save-off"; then
        error_exit "无法发送 save-off 命令，请检查 RCON 或 screen 配置"
    fi
    AUTOSAVE_DISABLED=true
    sleep 2

    if ! send_server_command "save-all"; then
        error_exit "无法发送 save-all 命令，请检查 RCON 或 screen 配置"
    fi
    sleep 5

    send_server_command "say §e[备份] 正在进行自动备份，可能会有短暂卡顿..." || true
    SERVER_RUNNING=true
else
    log "服务器未运行，直接备份..."
fi

# 4. 创建本地备份（压缩）
log "开始创建本地备份: $BACKUP_NAME"
cd "$SERVER_DIR" || error_exit "无法进入服务器目录"

# 排除一些不需要备份的文件
if tar -czf "$BACKUP_PATH" "${TAR_EXCLUDES[@]}" .; then
    BACKUP_SIZE=$(du -h "$BACKUP_PATH" | cut -f1)
    log "本地备份创建成功: $BACKUP_PATH (大小: $BACKUP_SIZE)"
else
    error_exit "本地备份创建失败"
fi

# 5. 恢复服务器自动保存
if [ "$SERVER_RUNNING" = true ]; then
    restore_autosave_if_needed
    send_server_command "say §a[备份] 本地备份完成！" || true
fi

# 6. 清理旧的本地备份
log "清理旧的本地备份 (保留最近 $MAX_BACKUPS 个)..."
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/minecraft-backup-*.tar.gz 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
    ls -1t "$BACKUP_DIR"/minecraft-backup-*.tar.gz | tail -n +$((MAX_BACKUPS + 1)) | while read old_backup; do
        log "删除旧备份: $(basename "$old_backup")"
        rm -f "$old_backup"
    done
fi

# 7. 推送到 GitHub
log "========== 开始推送到 GitHub =========="

cd "$SERVER_DIR" || error_exit "无法进入服务器目录"

# 检查是否有 git 仓库
if [ ! -d ".git" ]; then
    log "警告: 未检测到 git 仓库，跳过 GitHub 推送"
    log "如需启用 GitHub 备份，请先初始化 git 仓库"
    exit 0
fi

# 添加所有更改
log "添加文件到 git..."
run_and_log git add .

# 检查是否有更改
if git diff --cached --quiet; then
    log "没有检测到文件更改，跳过提交和推送"
else
    # 提交更改
    COMMIT_MSG="自动备份 - $(date '+%Y-%m-%d %H:%M:%S')"
    log "提交更改: $COMMIT_MSG"
    if run_and_log git commit -m "$COMMIT_MSG"; then
        log "提交成功"
    else
        error_exit "Git 提交失败"
    fi
    
    # 推送到 GitHub
    log "推送到 GitHub 远程仓库..."
    if run_and_log git push origin main; then
        log "GitHub 推送成功！"
        if [ "$SERVER_RUNNING" = true ]; then
            send_server_command "say §a[备份] GitHub 云端备份完成！" || true
        fi
    else
        log "警告: GitHub 推送失败，但本地备份已完成"
        if [ "$SERVER_RUNNING" = true ]; then
            send_server_command "say §e[备份] 本地备份完成，但云端同步失败" || true
        fi
    fi
fi

# 8. 生成备份报告
log "========== 备份统计 =========="
log "本地备份总数: $(ls -1 "$BACKUP_DIR"/minecraft-backup-*.tar.gz 2>/dev/null | wc -l) 个"
log "备份目录大小: $(du -sh "$BACKUP_DIR" | cut -f1)"
log "最新备份: $BACKUP_NAME ($BACKUP_SIZE)"

# 9. 检查磁盘空间
DISK_USAGE=$(df -h "$BACKUP_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')
log "磁盘使用率: ${DISK_USAGE}%"
if [ "$DISK_USAGE" -gt 90 ]; then
    log "警告: 磁盘空间不足，使用率已达 ${DISK_USAGE}%"
fi

log "========== 备份流程完成 =========="
echo ""
