#!/bin/bash

# Minecraft 服务器自动备份和 GitHub 推送脚本
# 作者: AI Assistant
# 日期: 2025-10-06

# ===== 配置部分 =====
SERVER_DIR="/root/minecraft-server"
BACKUP_DIR="/root/minecraft-backups"
LOG_FILE="$SERVER_DIR/backup-push.log"
MAX_BACKUPS=7  # 保留最近7个本地备份
MAX_LOG_LINES=1000  # 日志文件最大行数

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
    log "错误: $1"
    exit 1
}

# ===== 开始备份流程 =====
log "========== 开始备份流程 =========="

# 1. 创建备份目录
mkdir -p "$BACKUP_DIR" || error_exit "无法创建备份目录"

# 2. 生成备份文件名
BACKUP_NAME="minecraft-backup-$(date '+%Y%m%d-%H%M%S').tar.gz"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

# 3. 检查服务器是否正在运行
SCREEN_NAME="minecraft"
if screen -list | grep -q "$SCREEN_NAME"; then
    log "检测到服务器正在运行，发送保存命令..."
    
    # 关闭自动保存
    screen -S "$SCREEN_NAME" -p 0 -X stuff "save-off$(printf \\r)"
    sleep 2
    
    # 强制保存世界
    screen -S "$SCREEN_NAME" -p 0 -X stuff "save-all$(printf \\r)"
    sleep 5
    
    # 通知玩家
    screen -S "$SCREEN_NAME" -p 0 -X stuff "say §e[备份] 正在进行自动备份，可能会有短暂卡顿...$(printf \\r)"
    
    SERVER_RUNNING=true
else
    log "服务器未运行，直接备份..."
    SERVER_RUNNING=false
fi

# 4. 创建本地备份（压缩）
log "开始创建本地备份: $BACKUP_NAME"
cd "$SERVER_DIR" || error_exit "无法进入服务器目录"

# 排除一些不需要备份的文件
tar -czf "$BACKUP_PATH" \
    --exclude='*.log' \
    --exclude='logs/*' \
    --exclude='cache/*' \
    --exclude='.git/*' \
    --exclude='*.jar.old' \
    --exclude='backup-push.log' \
    . 2>&1 | grep -v "Removing leading" | while read line; do
        if [ ! -z "$line" ]; then
            log "  $line"
        fi
    done

if [ $? -eq 0 ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_PATH" | cut -f1)
    log "本地备份创建成功: $BACKUP_PATH (大小: $BACKUP_SIZE)"
else
    error_exit "本地备份创建失败"
fi

# 5. 恢复服务器自动保存
if [ "$SERVER_RUNNING" = true ]; then
    screen -S "$SCREEN_NAME" -p 0 -X stuff "save-on$(printf \\r)"
    screen -S "$SCREEN_NAME" -p 0 -X stuff "say §a[备份] 本地备份完成！$(printf \\r)"
    log "已恢复服务器自动保存"
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
git add . 2>&1 | while read line; do log "  $line"; done

# 检查是否有更改
if git diff --cached --quiet; then
    log "没有检测到文件更改，跳过提交和推送"
else
    # 提交更改
    COMMIT_MSG="自动备份 - $(date '+%Y-%m-%d %H:%M:%S')"
    log "提交更改: $COMMIT_MSG"
    git commit -m "$COMMIT_MSG" 2>&1 | while read line; do log "  $line"; done
    
    if [ $? -eq 0 ]; then
        log "提交成功"
    else
        error_exit "Git 提交失败"
    fi
    
    # 推送到 GitHub
    log "推送到 GitHub 远程仓库..."
    git push origin main 2>&1 | while read line; do log "  $line"; done
    
    if [ $? -eq 0 ]; then
        log "GitHub 推送成功！"
        if [ "$SERVER_RUNNING" = true ]; then
            screen -S "$SCREEN_NAME" -p 0 -X stuff "say §a[备份] GitHub 云端备份完成！$(printf \\r)"
        fi
    else
        log "警告: GitHub 推送失败，但本地备份已完成"
        if [ "$SERVER_RUNNING" = true ]; then
            screen -S "$SCREEN_NAME" -p 0 -X stuff "say §e[备份] 本地备份完成，但云端同步失败$(printf \\r)"
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

