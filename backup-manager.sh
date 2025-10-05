#!/bin/bash

###############################################################################
# Minecraft 服务器备份管理工具
# 功能：查看、删除、统计备份
###############################################################################

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

BACKUP_DIR="/root/minecraft-server/backups"

show_menu() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Minecraft 备份管理工具${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo -e "${CYAN}1.${NC} 查看所有备份"
    echo -e "${CYAN}2.${NC} 查看备份统计"
    echo -e "${CYAN}3.${NC} 立即执行备份"
    echo -e "${CYAN}4.${NC} 删除指定备份"
    echo -e "${CYAN}5.${NC} 清理所有旧备份"
    echo -e "${CYAN}6.${NC} 查看备份日志"
    echo -e "${CYAN}0.${NC} 退出"
    echo ""
    echo -e "${YELLOW}请选择操作：${NC}"
}

list_all_backups() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  所有备份列表${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    echo -e "${CYAN}=== 小时备份 ===${NC}"
    if [ -d "$BACKUP_DIR/hourly" ]; then
        ls -lh "$BACKUP_DIR/hourly" 2>/dev/null | grep "backup-" | awk '{print $9, "("$5")", $6, $7, $8}' | nl -w2 -s". " || echo "  无备份"
    else
        echo "  无备份"
    fi
    echo ""

    echo -e "${CYAN}=== 每日备份 ===${NC}"
    if [ -d "$BACKUP_DIR/daily" ]; then
        ls -lh "$BACKUP_DIR/daily" 2>/dev/null | grep "backup-" | awk '{print $9, "("$5")", $6, $7, $8}' | nl -w2 -s". " || echo "  无备份"
    else
        echo "  无备份"
    fi
    echo ""

    echo -e "${CYAN}=== 每周备份 ===${NC}"
    if [ -d "$BACKUP_DIR/weekly" ]; then
        ls -lh "$BACKUP_DIR/weekly" 2>/dev/null | grep "backup-" | awk '{print $9, "("$5")", $6, $7, $8}' | nl -w2 -s". " || echo "  无备份"
    else
        echo "  无备份"
    fi
    echo ""

    echo -e "${CYAN}=== 每月备份 ===${NC}"
    if [ -d "$BACKUP_DIR/monthly" ]; then
        ls -lh "$BACKUP_DIR/monthly" 2>/dev/null | grep "backup-" | awk '{print $9, "("$5")", $6, $7, $8}' | nl -w2 -s". " || echo "  无备份"
    else
        echo "  无备份"
    fi
    echo ""
}

show_statistics() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  备份统计信息${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    HOURLY_COUNT=$(ls -1 "$BACKUP_DIR/hourly" 2>/dev/null | grep -c "backup-" || echo 0)
    DAILY_COUNT=$(ls -1 "$BACKUP_DIR/daily" 2>/dev/null | grep -c "backup-" || echo 0)
    WEEKLY_COUNT=$(ls -1 "$BACKUP_DIR/weekly" 2>/dev/null | grep -c "backup-" || echo 0)
    MONTHLY_COUNT=$(ls -1 "$BACKUP_DIR/monthly" 2>/dev/null | grep -c "backup-" || echo 0)
    TOTAL_COUNT=$((HOURLY_COUNT + DAILY_COUNT + WEEKLY_COUNT + MONTHLY_COUNT))

    echo -e "${CYAN}备份数量：${NC}"
    echo -e "  小时备份: ${GREEN}$HOURLY_COUNT${NC} 个"
    echo -e "  每日备份: ${GREEN}$DAILY_COUNT${NC} 个"
    echo -e "  每周备份: ${GREEN}$WEEKLY_COUNT${NC} 个"
    echo -e "  每月备份: ${GREEN}$MONTHLY_COUNT${NC} 个"
    echo -e "  ${YELLOW}总计: $TOTAL_COUNT 个${NC}"
    echo ""

    echo -e "${CYAN}存储空间：${NC}"
    if [ -d "$BACKUP_DIR/hourly" ]; then
        HOURLY_SIZE=$(du -sh "$BACKUP_DIR/hourly" 2>/dev/null | awk '{print $1}')
        echo -e "  小时备份: ${GREEN}$HOURLY_SIZE${NC}"
    fi
    if [ -d "$BACKUP_DIR/daily" ]; then
        DAILY_SIZE=$(du -sh "$BACKUP_DIR/daily" 2>/dev/null | awk '{print $1}')
        echo -e "  每日备份: ${GREEN}$DAILY_SIZE${NC}"
    fi
    if [ -d "$BACKUP_DIR/weekly" ]; then
        WEEKLY_SIZE=$(du -sh "$BACKUP_DIR/weekly" 2>/dev/null | awk '{print $1}')
        echo -e "  每周备份: ${GREEN}$WEEKLY_SIZE${NC}"
    fi
    if [ -d "$BACKUP_DIR/monthly" ]; then
        MONTHLY_SIZE=$(du -sh "$BACKUP_DIR/monthly" 2>/dev/null | awk '{print $1}')
        echo -e "  每月备份: ${GREEN}$MONTHLY_SIZE${NC}"
    fi

    TOTAL_SIZE=$(du -sh "$BACKUP_DIR" 2>/dev/null | awk '{print $1}')
    echo -e "  ${YELLOW}总计: $TOTAL_SIZE${NC}"
    echo ""

    # 最新和最旧备份
    NEWEST=$(find "$BACKUP_DIR" -name "backup-*.tar.gz" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | awk '{print $2}')
    OLDEST=$(find "$BACKUP_DIR" -name "backup-*.tar.gz" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | head -1 | awk '{print $2}')

    if [ -n "$NEWEST" ]; then
        NEWEST_NAME=$(basename "$NEWEST")
        NEWEST_TIME=$(stat -c %y "$NEWEST" 2>/dev/null | cut -d. -f1)
        echo -e "${CYAN}最新备份：${NC}$NEWEST_NAME"
        echo -e "  时间: ${GREEN}$NEWEST_TIME${NC}"
    fi

    if [ -n "$OLDEST" ]; then
        OLDEST_NAME=$(basename "$OLDEST")
        OLDEST_TIME=$(stat -c %y "$OLDEST" 2>/dev/null | cut -d. -f1)
        echo -e "${CYAN}最旧备份：${NC}$OLDEST_NAME"
        echo -e "  时间: ${GREEN}$OLDEST_TIME${NC}"
    fi
    echo ""
}

run_backup() {
    echo -e "${YELLOW}正在执行备份...${NC}"
    echo ""
    /root/minecraft-server/auto-backup.sh
    echo ""
    echo -e "${GREEN}备份完成！${NC}"
}

delete_backup() {
    echo -e "${YELLOW}请输入要删除的备份文件完整路径：${NC}"
    read -r BACKUP_FILE

    if [ ! -f "$BACKUP_FILE" ]; then
        echo -e "${RED}错误：文件不存在！${NC}"
        return
    fi

    echo -e "${RED}确认删除：${NC}$BACKUP_FILE"
    echo -e "${YELLOW}是否继续？(yes/no)${NC}"
    read -r CONFIRM

    if [ "$CONFIRM" = "yes" ]; then
        rm -f "$BACKUP_FILE"
        echo -e "${GREEN}✓ 备份已删除${NC}"
    else
        echo -e "${BLUE}操作已取消${NC}"
    fi
}

clean_old_backups() {
    echo -e "${RED}警告：此操作将删除所有超过保留策略的旧备份！${NC}"
    echo -e "${YELLOW}是否继续？(yes/no)${NC}"
    read -r CONFIRM

    if [ "$CONFIRM" != "yes" ]; then
        echo -e "${BLUE}操作已取消${NC}"
        return
    fi

    echo -e "${YELLOW}清理旧备份...${NC}"

    # 保留策略
    KEEP_HOURLY=24
    KEEP_DAILY=7
    KEEP_WEEKLY=4
    KEEP_MONTHLY=3

    # 清理小时备份
    cd "$BACKUP_DIR/hourly" 2>/dev/null
    DELETED=$(ls -t backup-*.tar.gz 2>/dev/null | tail -n +$((KEEP_HOURLY + 1)) | wc -l)
    ls -t backup-*.tar.gz 2>/dev/null | tail -n +$((KEEP_HOURLY + 1)) | xargs -r rm -f
    echo -e "${GREEN}✓ 清理小时备份: $DELETED 个${NC}"

    # 清理每日备份
    cd "$BACKUP_DIR/daily" 2>/dev/null
    DELETED=$(ls -t backup-*.tar.gz 2>/dev/null | tail -n +$((KEEP_DAILY + 1)) | wc -l)
    ls -t backup-*.tar.gz 2>/dev/null | tail -n +$((KEEP_DAILY + 1)) | xargs -r rm -f
    echo -e "${GREEN}✓ 清理每日备份: $DELETED 个${NC}"

    # 清理每周备份
    cd "$BACKUP_DIR/weekly" 2>/dev/null
    DELETED=$(ls -t backup-*.tar.gz 2>/dev/null | tail -n +$((KEEP_WEEKLY + 1)) | wc -l)
    ls -t backup-*.tar.gz 2>/dev/null | tail -n +$((KEEP_WEEKLY + 1)) | xargs -r rm -f
    echo -e "${GREEN}✓ 清理每周备份: $DELETED 个${NC}"

    # 清理每月备份
    cd "$BACKUP_DIR/monthly" 2>/dev/null
    DELETED=$(ls -t backup-*.tar.gz 2>/dev/null | tail -n +$((KEEP_MONTHLY + 1)) | wc -l)
    ls -t backup-*.tar.gz 2>/dev/null | tail -n +$((KEEP_MONTHLY + 1)) | xargs -r rm -f
    echo -e "${GREEN}✓ 清理每月备份: $DELETED 个${NC}"

    echo ""
    echo -e "${GREEN}清理完成！${NC}"
}

view_logs() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  备份日志（最近10次）${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    if [ -f "/var/log/minecraft-backup.log" ]; then
        tail -50 /var/log/minecraft-backup.log
    else
        echo -e "${YELLOW}暂无日志记录${NC}"
        echo -e "${BLUE}日志将在首次自动备份后生成${NC}"
    fi
}

# 主循环
while true; do
    show_menu
    read -r choice

    case $choice in
        1)
            list_all_backups
            ;;
        2)
            show_statistics
            ;;
        3)
            run_backup
            ;;
        4)
            delete_backup
            ;;
        5)
            clean_old_backups
            ;;
        6)
            view_logs
            ;;
        0)
            echo -e "${GREEN}再见！${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}无效的选择！${NC}"
            ;;
    esac

    echo ""
    echo -e "${YELLOW}按 Enter 继续...${NC}"
    read -r
done
