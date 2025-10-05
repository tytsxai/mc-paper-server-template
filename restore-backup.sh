#!/bin/bash

###############################################################################
# Minecraft 服务器备份恢复脚本
# 功能：从备份文件恢复服务器数据
# 特点：安全检查、自动停服、数据验证
###############################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SERVER_DIR="/root/minecraft-server"
BACKUP_DIR="/root/minecraft-server/backups"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Minecraft 服务器备份恢复工具${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查服务器是否在运行
if screen -list | grep -q "minecraft"; then
    echo -e "${RED}错误：服务器正在运行！${NC}"
    echo -e "${YELLOW}请先停止服务器再进行恢复操作${NC}"
    echo -e "${YELLOW}运行命令：./stop.sh${NC}"
    exit 1
fi

# 列出可用的备份
echo -e "${YELLOW}可用的备份文件：${NC}"
echo ""

echo -e "${CYAN}=== 小时备份（最近24小时）===${NC}"
ls -lh "$BACKUP_DIR/hourly" 2>/dev/null | grep "backup-" | awk '{print $9, "("$5")"}' | nl -w2 -s". " || echo "  无"
echo ""

echo -e "${CYAN}=== 每日备份（最近7天）===${NC}"
ls -lh "$BACKUP_DIR/daily" 2>/dev/null | grep "backup-" | awk '{print $9, "("$5")"}' | nl -w2 -s". " || echo "  无"
echo ""

echo -e "${CYAN}=== 每周备份（最近4周）===${NC}"
ls -lh "$BACKUP_DIR/weekly" 2>/dev/null | grep "backup-" | awk '{print $9, "("$5")"}' | nl -w2 -s". " || echo "  无"
echo ""

echo -e "${CYAN}=== 每月备份（最近3个月）===${NC}"
ls -lh "$BACKUP_DIR/monthly" 2>/dev/null | grep "backup-" | awk '{print $9, "("$5")"}' | nl -w2 -s". " || echo "  无"
echo ""

# 输入备份文件名
echo -e "${YELLOW}请输入要恢复的备份文件名（完整路径）：${NC}"
echo -e "${BLUE}例如：$BACKUP_DIR/hourly/backup-20251005-140000.tar.gz${NC}"
read -r BACKUP_FILE

# 检查文件是否存在
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}错误：备份文件不存在！${NC}"
    exit 1
fi

echo ""
echo -e "${RED}警告：恢复操作将覆盖当前的服务器数据！${NC}"
echo -e "${YELLOW}建份文件：${NC}$BACKUP_FILE"
echo -e "${YELLOW}目标目录：${NC}$SERVER_DIR"
echo ""
echo -e "${YELLOW}是否继续？(yes/no)${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${BLUE}操作已取消${NC}"
    exit 0
fi

# 创建当前数据的备份
echo ""
echo -e "${YELLOW}创建当前数据的安全备份...${NC}"
SAFETY_BACKUP="$BACKUP_DIR/safety-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
tar -czf "$SAFETY_BACKUP" -C "$SERVER_DIR" world world_nether world_the_end plugins/*.yml 2>/dev/null || true
echo -e "${GREEN}✓ 安全备份已创建：$SAFETY_BACKUP${NC}"

# 解压备份文件
echo ""
echo -e "${YELLOW}解压备份文件...${NC}"
TEMP_RESTORE="$BACKUP_DIR/temp-restore-$$"
mkdir -p "$TEMP_RESTORE"
tar -xzf "$BACKUP_FILE" -C "$TEMP_RESTORE"

# 查找解压后的目录
EXTRACTED_DIR=$(find "$TEMP_RESTORE" -maxdepth 1 -type d -name "temp-*" | head -1)

if [ -z "$EXTRACTED_DIR" ]; then
    echo -e "${RED}错误：无法找到解压后的数据！${NC}"
    rm -rf "$TEMP_RESTORE"
    exit 1
fi

echo -e "${GREEN}✓ 备份文件解压完成${NC}"

# 恢复世界数据
echo ""
echo -e "${YELLOW}恢复世界数据...${NC}"

if [ -d "$EXTRACTED_DIR/world" ]; then
    rm -rf "$SERVER_DIR/world"
    cp -r "$EXTRACTED_DIR/world" "$SERVER_DIR/"
    echo -e "${GREEN}✓ world 已恢复${NC}"
fi

if [ -d "$EXTRACTED_DIR/world_nether" ]; then
    rm -rf "$SERVER_DIR/world_nether"
    cp -r "$EXTRACTED_DIR/world_nether" "$SERVER_DIR/"
    echo -e "${GREEN}✓ world_nether 已恢复${NC}"
fi

if [ -d "$EXTRACTED_DIR/world_the_end" ]; then
    rm -rf "$SERVER_DIR/world_the_end"
    cp -r "$EXTRACTED_DIR/world_the_end" "$SERVER_DIR/"
    echo -e "${GREEN}✓ world_the_end 已恢复${NC}"
fi

# 恢复插件配置
if [ -d "$EXTRACTED_DIR/plugins-config" ]; then
    echo ""
    echo -e "${YELLOW}恢复插件配置...${NC}"
    cp -r "$EXTRACTED_DIR/plugins-config"/* "$SERVER_DIR/plugins/" 2>/dev/null || true
    echo -e "${GREEN}✓ 插件配置已恢复${NC}"
fi

# 恢复玩家数据
if [ -d "$EXTRACTED_DIR/player-data" ]; then
    echo ""
    echo -e "${YELLOW}恢复玩家数据...${NC}"

    if [ -d "$EXTRACTED_DIR/player-data/AuthMe" ]; then
        rm -rf "$SERVER_DIR/plugins/AuthMe/PlayerData"
        cp -r "$EXTRACTED_DIR/player-data/AuthMe" "$SERVER_DIR/plugins/AuthMe/PlayerData" 2>/dev/null || true
        echo -e "${GREEN}✓ AuthMe 玩家数据已恢复${NC}"
    fi

    if [ -d "$EXTRACTED_DIR/player-data/LuckPerms" ]; then
        rm -rf "$SERVER_DIR/plugins/LuckPerms"
        cp -r "$EXTRACTED_DIR/player-data/LuckPerms" "$SERVER_DIR/plugins/" 2>/dev/null || true
        echo -e "${GREEN}✓ LuckPerms 权限数据已恢复${NC}"
    fi

    if [ -d "$EXTRACTED_DIR/player-data/Essentials" ]; then
        rm -rf "$SERVER_DIR/plugins/Essentials/userdata"
        cp -r "$EXTRACTED_DIR/player-data/Essentials" "$SERVER_DIR/plugins/Essentials/userdata" 2>/dev/null || true
        echo -e "${GREEN}✓ Essentials 玩家数据已恢复${NC}"
    fi
fi

# 恢复服务器配置
if [ -d "$EXTRACTED_DIR/server-config" ]; then
    echo ""
    echo -e "${YELLOW}恢复服务器配置...${NC}"
    cp "$EXTRACTED_DIR/server-config"/* "$SERVER_DIR/" 2>/dev/null || true
    echo -e "${GREEN}✓ 服务器配置已恢复${NC}"
fi

# 清理临时文件
rm -rf "$TEMP_RESTORE"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✓ 恢复完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}安全备份位置：${NC}$SAFETY_BACKUP"
echo -e "${YELLOW}如需撤销恢复，可使用此安全备份${NC}"
echo ""
echo -e "${BLUE}现在可以启动服务器：${NC}./start.sh"
echo ""
