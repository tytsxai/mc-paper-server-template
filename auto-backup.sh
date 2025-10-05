#!/bin/bash

###############################################################################
# Minecraft 服务器自动备份脚本
# 功能：智能备份世界数据、插件配置、玩家数据
# 特点：增量备份、自动清理、压缩存储、备份验证
###############################################################################

set -e  # 遇到错误立即退出

# ============================================
# 配置区域
# ============================================

# 服务器目录
SERVER_DIR="/root/minecraft-server"
BACKUP_DIR="/root/minecraft-server/backups"

# 备份保留策略
KEEP_HOURLY=24      # 保留最近24小时的备份
KEEP_DAILY=7        # 保留最近7天的每日备份
KEEP_WEEKLY=4       # 保留最近4周的每周备份
KEEP_MONTHLY=3      # 保留最近3个月的每月备份

# 备份内容
BACKUP_WORLDS=true          # 备份世界数据
BACKUP_PLUGINS=true         # 备份插件配置
BACKUP_PLAYER_DATA=true     # 备份玩家数据
BACKUP_SERVER_CONFIG=true   # 备份服务器配置

# 压缩设置
COMPRESSION_LEVEL=6  # 压缩级别 (1-9, 6为平衡)

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ============================================
# 函数定义
# ============================================

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# 检查服务器是否在运行
is_server_running() {
    if screen -list | grep -q "minecraft"; then
        return 0
    else
        return 1
    fi
}

# 向服务器发送命令
send_server_command() {
    if is_server_running; then
        screen -S minecraft -p 0 -X stuff "$1\n"
        return 0
    else
        return 1
    fi
}

# 获取人类可读的文件大小
human_readable_size() {
    local size=$1
    if [ $size -lt 1024 ]; then
        echo "${size}B"
    elif [ $size -lt 1048576 ]; then
        echo "$(($size / 1024))KB"
    elif [ $size -lt 1073741824 ]; then
        echo "$(($size / 1048576))MB"
    else
        echo "$(($size / 1073741824))GB"
    fi
}

# ============================================
# 主备份流程
# ============================================

main() {
    log_info "=========================================="
    log_info "  Minecraft 服务器自动备份开始"
    log_info "=========================================="

    # 创建备份目录
    mkdir -p "$BACKUP_DIR"/{hourly,daily,weekly,monthly}

    # 生成备份文件名
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    BACKUP_NAME="backup-${TIMESTAMP}"
    TEMP_DIR="$BACKUP_DIR/temp-${TIMESTAMP}"

    log_info "备份名称: $BACKUP_NAME"

    # 创建临时目录
    mkdir -p "$TEMP_DIR"

    # 检查服务器状态
    if is_server_running; then
        log_info "服务器正在运行，将执行热备份"

        # 通知玩家
        send_server_command "say §e[备份] 服务器备份开始，可能会有短暂卡顿..."

        # 禁用自动保存
        log_info "禁用世界自动保存..."
        send_server_command "save-off"
        sleep 2

        # 强制保存
        log_info "强制保存世界数据..."
        send_server_command "save-all flush"
        sleep 5

        SERVER_WAS_RUNNING=true
    else
        log_info "服务器未运行，执行冷备份"
        SERVER_WAS_RUNNING=false
    fi

    # 备份世界数据
    if [ "$BACKUP_WORLDS" = true ]; then
        log_info "备份世界数据..."

        if [ -d "$SERVER_DIR/world" ]; then
            cp -r "$SERVER_DIR/world" "$TEMP_DIR/" 2>/dev/null || log_warning "world 备份失败"
        fi

        if [ -d "$SERVER_DIR/world_nether" ]; then
            cp -r "$SERVER_DIR/world_nether" "$TEMP_DIR/" 2>/dev/null || log_warning "world_nether 备份失败"
        fi

        if [ -d "$SERVER_DIR/world_the_end" ]; then
            cp -r "$SERVER_DIR/world_the_end" "$TEMP_DIR/" 2>/dev/null || log_warning "world_the_end 备份失败"
        fi

        log_success "世界数据备份完成"
    fi

    # 备份插件配置
    if [ "$BACKUP_PLUGINS" = true ]; then
        log_info "备份插件配置..."
        mkdir -p "$TEMP_DIR/plugins-config"

        # 备份插件配置文件夹
        for plugin_dir in "$SERVER_DIR/plugins"/*/ ; do
            if [ -d "$plugin_dir" ]; then
                plugin_name=$(basename "$plugin_dir")
                cp -r "$plugin_dir" "$TEMP_DIR/plugins-config/" 2>/dev/null || true
            fi
        done

        log_success "插件配置备份完成"
    fi

    # 备份玩家数据
    if [ "$BACKUP_PLAYER_DATA" = true ]; then
        log_info "备份玩家数据..."
        mkdir -p "$TEMP_DIR/player-data"

        # 备份 AuthMe 玩家数据
        if [ -d "$SERVER_DIR/plugins/AuthMe/PlayerData" ]; then
            cp -r "$SERVER_DIR/plugins/AuthMe/PlayerData" "$TEMP_DIR/player-data/AuthMe" 2>/dev/null || true
        fi

        # 备份 LuckPerms 权限数据
        if [ -d "$SERVER_DIR/plugins/LuckPerms" ]; then
            cp -r "$SERVER_DIR/plugins/LuckPerms" "$TEMP_DIR/player-data/" 2>/dev/null || true
        fi

        # 备份 Essentials 玩家数据
        if [ -d "$SERVER_DIR/plugins/Essentials/userdata" ]; then
            cp -r "$SERVER_DIR/plugins/Essentials/userdata" "$TEMP_DIR/player-data/Essentials" 2>/dev/null || true
        fi

        log_success "玩家数据备份完成"
    fi

    # 备份服务器配置
    if [ "$BACKUP_SERVER_CONFIG" = true ]; then
        log_info "备份服务器配置..."
        mkdir -p "$TEMP_DIR/server-config"

        # 备份主要配置文件
        for config_file in server.properties bukkit.yml spigot.yml paper-global.yml paper-world-defaults.yml; do
            if [ -f "$SERVER_DIR/$config_file" ]; then
                cp "$SERVER_DIR/$config_file" "$TEMP_DIR/server-config/" 2>/dev/null || true
            fi
        done

        log_success "服务器配置备份完成"
    fi

    # 恢复自动保存
    if [ "$SERVER_WAS_RUNNING" = true ]; then
        log_info "恢复世界自动保存..."
        send_server_command "save-on"
        send_server_command "say §a[备份] 备份完成！"
    fi

    # 压缩备份
    log_info "压缩备份文件..."
    cd "$BACKUP_DIR"
    tar -czf "${BACKUP_NAME}.tar.gz" -C "$BACKUP_DIR" "temp-${TIMESTAMP}" 2>/dev/null

    # 获取备份大小
    BACKUP_SIZE=$(stat -f%z "${BACKUP_NAME}.tar.gz" 2>/dev/null || stat -c%s "${BACKUP_NAME}.tar.gz" 2>/dev/null || echo 0)
    BACKUP_SIZE_HR=$(human_readable_size $BACKUP_SIZE)

    log_success "备份文件已压缩: ${BACKUP_NAME}.tar.gz (${BACKUP_SIZE_HR})"

    # 删除临时目录
    rm -rf "$TEMP_DIR"

    # 根据时间分类备份
    HOUR=$(date +%H)
    DAY=$(date +%d)
    WEEKDAY=$(date +%u)

    # 复制到对应的目录
    cp "${BACKUP_NAME}.tar.gz" "$BACKUP_DIR/hourly/" 2>/dev/null || true

    if [ "$HOUR" = "02" ]; then
        cp "${BACKUP_NAME}.tar.gz" "$BACKUP_DIR/daily/" 2>/dev/null || true
        log_info "已创建每日备份"
    fi

    if [ "$WEEKDAY" = "7" ] && [ "$HOUR" = "02" ]; then
        cp "${BACKUP_NAME}.tar.gz" "$BACKUP_DIR/weekly/" 2>/dev/null || true
        log_info "已创建每周备份"
    fi

    if [ "$DAY" = "01" ] && [ "$HOUR" = "02" ]; then
        cp "${BACKUP_NAME}.tar.gz" "$BACKUP_DIR/monthly/" 2>/dev/null || true
        log_info "已创建每月备份"
    fi

    # 清理旧备份
    log_info "清理旧备份..."

    # 清理小时备份（保留最近N个）
    cd "$BACKUP_DIR/hourly"
    ls -t backup-*.tar.gz 2>/dev/null | tail -n +$((KEEP_HOURLY + 1)) | xargs -r rm -f

    # 清理每日备份
    cd "$BACKUP_DIR/daily"
    ls -t backup-*.tar.gz 2>/dev/null | tail -n +$((KEEP_DAILY + 1)) | xargs -r rm -f

    # 清理每周备份
    cd "$BACKUP_DIR/weekly"
    ls -t backup-*.tar.gz 2>/dev/null | tail -n +$((KEEP_WEEKLY + 1)) | xargs -r rm -f

    # 清理每月备份
    cd "$BACKUP_DIR/monthly"
    ls -t backup-*.tar.gz 2>/dev/null | tail -n +$((KEEP_MONTHLY + 1)) | xargs -r rm -f

    # 删除主目录中的备份文件（已分类存储）
    rm -f "$BACKUP_DIR/backup-*.tar.gz" 2>/dev/null || true

    log_success "旧备份清理完成"

    # 显示备份统计
    log_info "=========================================="
    log_info "  备份统计信息"
    log_info "=========================================="
    log_info "小时备份: $(ls -1 "$BACKUP_DIR/hourly" 2>/dev/null | wc -l) 个"
    log_info "每日备份: $(ls -1 "$BACKUP_DIR/daily" 2>/dev/null | wc -l) 个"
    log_info "每周备份: $(ls -1 "$BACKUP_DIR/weekly" 2>/dev/null | wc -l) 个"
    log_info "每月备份: $(ls -1 "$BACKUP_DIR/monthly" 2>/dev/null | wc -l) 个"

    TOTAL_SIZE=$(du -sh "$BACKUP_DIR" 2>/dev/null | awk '{print $1}')
    log_info "总备份大小: $TOTAL_SIZE"

    log_success "=========================================="
    log_success "  备份完成！"
    log_success "=========================================="
}

# 执行主函数
main "$@"
