#!/bin/bash

# Minecraft 服务器备份管理工具

DIR="$(cd "$(dirname "$0")" && pwd)"
SERVER_DIR="${SERVER_DIR:-$DIR}"
BACKUP_DIR="${BACKUP_DIR:-$SERVER_DIR/backups}"
LOG_FILE="${LOG_FILE:-$SERVER_DIR/backup-push.log}"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示菜单
show_menu() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Minecraft 备份管理工具${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    echo "1. 立即执行备份并推送到 GitHub"
    echo "2. 查看本地备份列表"
    echo "3. 查看备份日志（最近 50 行）"
    echo "4. 查看完整备份日志"
    echo "5. 查看备份统计信息"
    echo "6. 查看 GitHub 同步状态"
    echo "7. 手动推送到 GitHub"
    echo "8. 从 GitHub 拉取最新版本"
    echo "9. 删除指定备份"
    echo "10. 清理旧备份（保留最近 3 个）"
    echo "11. 查看定时任务配置"
    echo "12. 测试 GitHub SSH 连接"
    echo "0. 退出"
    echo ""
    echo -n "请选择操作 [0-12]: "
}

# 1. 立即执行备份
do_backup() {
    echo -e "${GREEN}正在执行备份...${NC}"
    cd "$SERVER_DIR"
    ./auto-backup-and-push.sh
    echo ""
    echo -e "${GREEN}备份完成！${NC}"
    read -p "按回车键继续..."
}

# 2. 查看本地备份列表
list_backups() {
    echo -e "${BLUE}本地备份列表:${NC}"
    echo ""
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR/*.tar.gz 2>/dev/null)" ]; then
        echo -e "${YELLOW}暂无备份文件${NC}"
    else
        ls -lh "$BACKUP_DIR"/*.tar.gz | awk '{printf "%2d. %s %s  %s\n", NR, $9, $5, $6" "$7" "$8}'
        echo ""
        echo -e "${GREEN}备份总数:${NC} $(ls -1 $BACKUP_DIR/*.tar.gz 2>/dev/null | wc -l) 个"
        echo -e "${GREEN}占用空间:${NC} $(du -sh $BACKUP_DIR 2>/dev/null | cut -f1)"
    fi
    echo ""
    read -p "按回车键继续..."
}

# 3. 查看最近备份日志
view_recent_log() {
    echo -e "${BLUE}最近 50 行备份日志:${NC}"
    echo ""
    if [ -f "$LOG_FILE" ]; then
        tail -n 50 "$LOG_FILE"
    else
        echo -e "${YELLOW}日志文件不存在${NC}"
    fi
    echo ""
    read -p "按回车键继续..."
}

# 4. 查看完整日志
view_full_log() {
    if [ -f "$LOG_FILE" ]; then
        less "$LOG_FILE"
    else
        echo -e "${YELLOW}日志文件不存在${NC}"
        read -p "按回车键继续..."
    fi
}

# 5. 查看备份统计
show_stats() {
    echo -e "${BLUE}备份统计信息:${NC}"
    echo ""
    
    # 本地备份统计
    if [ -d "$BACKUP_DIR" ]; then
        local backup_count=$(ls -1 $BACKUP_DIR/*.tar.gz 2>/dev/null | wc -l)
        local backup_size=$(du -sh $BACKUP_DIR 2>/dev/null | cut -f1)
        echo -e "${GREEN}本地备份:${NC}"
        echo "  - 备份数量: $backup_count 个"
        echo "  - 占用空间: $backup_size"
        
        if [ $backup_count -gt 0 ]; then
            local latest=$(ls -t $BACKUP_DIR/*.tar.gz 2>/dev/null | head -n 1)
            local latest_name=$(basename "$latest")
            local latest_size=$(du -h "$latest" 2>/dev/null | cut -f1)
            local latest_time=$(stat -c %y "$latest" 2>/dev/null | cut -d'.' -f1)
            echo "  - 最新备份: $latest_name"
            echo "  - 备份大小: $latest_size"
            echo "  - 备份时间: $latest_time"
        fi
    fi
    
    echo ""
    
    # Git 统计
    if [ -d "$SERVER_DIR/.git" ]; then
        echo -e "${GREEN}Git 仓库:${NC}"
        cd "$SERVER_DIR"
        echo "  - 分支: $(git branch --show-current)"
        echo "  - 最后提交: $(git log -1 --pretty=format:'%h - %s (%cr)' 2>/dev/null)"
        echo "  - 远程仓库: $(git remote get-url origin 2>/dev/null)"
    fi
    
    echo ""
    
    # 磁盘使用率
    echo -e "${GREEN}磁盘状态:${NC}"
    df -h "$SERVER_DIR" | awk 'NR==2 {printf "  - 使用率: %s / %s (%s)\n", $3, $2, $5}'
    
    local usage=$(df -h "$SERVER_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$usage" -gt 90 ]; then
        echo -e "  ${RED}警告: 磁盘空间不足！${NC}"
    elif [ "$usage" -gt 80 ]; then
        echo -e "  ${YELLOW}提示: 磁盘空间使用较高${NC}"
    fi
    
    echo ""
    read -p "按回车键继续..."
}

# 6. 查看 GitHub 状态
check_github_status() {
    echo -e "${BLUE}GitHub 同步状态:${NC}"
    echo ""
    
    if [ ! -d "$SERVER_DIR/.git" ]; then
        echo -e "${RED}错误: 未检测到 git 仓库${NC}"
    else
        cd "$SERVER_DIR"
        
        echo -e "${GREEN}远程仓库:${NC}"
        git remote -v
        echo ""
        
        echo -e "${GREEN}当前状态:${NC}"
        git status
        echo ""
        
        echo -e "${GREEN}最近 5 次提交:${NC}"
        git log -5 --oneline --decorate
    fi
    
    echo ""
    read -p "按回车键继续..."
}

# 7. 手动推送到 GitHub
push_to_github() {
    echo -e "${YELLOW}准备推送到 GitHub...${NC}"
    
    if [ ! -d "$SERVER_DIR/.git" ]; then
        echo -e "${RED}错误: 未检测到 git 仓库${NC}"
    else
        cd "$SERVER_DIR"
        
        echo "添加文件..."
        git add .
        
        if git diff --cached --quiet; then
            echo -e "${YELLOW}没有检测到更改${NC}"
        else
            echo -n "请输入提交信息 (直接回车使用默认): "
            read commit_msg
            
            if [ -z "$commit_msg" ]; then
                commit_msg="手动备份 - $(date '+%Y-%m-%d %H:%M:%S')"
            fi
            
            echo "提交更改..."
            git commit -m "$commit_msg"
            
            echo "推送到 GitHub..."
            git push origin main
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}推送成功！${NC}"
            else
                echo -e "${RED}推送失败！${NC}"
            fi
        fi
    fi
    
    echo ""
    read -p "按回车键继续..."
}

# 8. 从 GitHub 拉取
pull_from_github() {
    echo -e "${YELLOW}警告: 这将用 GitHub 上的版本覆盖本地更改！${NC}"
    echo -n "确定要继续吗? (yes/no): "
    read confirm
    
    if [ "$confirm" = "yes" ]; then
        cd "$SERVER_DIR"
        echo "从 GitHub 拉取最新版本..."
        git pull origin main
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}拉取成功！${NC}"
        else
            echo -e "${RED}拉取失败！${NC}"
        fi
    else
        echo "操作已取消"
    fi
    
    echo ""
    read -p "按回车键继续..."
}

# 9. 删除指定备份
delete_backup() {
    list_backups
    echo -n "请输入要删除的备份编号 (0 取消): "
    read num
    
    if [ "$num" = "0" ]; then
        echo "操作已取消"
    elif [ -n "$num" ] && [ "$num" -gt 0 ]; then
        local backup_file=$(ls -1t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | sed -n "${num}p")
        
        if [ -n "$backup_file" ]; then
            echo -e "${YELLOW}将删除: $(basename $backup_file)${NC}"
            echo -n "确认删除? (yes/no): "
            read confirm
            
            if [ "$confirm" = "yes" ]; then
                rm -f "$backup_file"
                echo -e "${GREEN}删除成功！${NC}"
            else
                echo "操作已取消"
            fi
        else
            echo -e "${RED}无效的编号${NC}"
        fi
    else
        echo -e "${RED}无效的输入${NC}"
    fi
    
    echo ""
    read -p "按回车键继续..."
}

# 10. 清理旧备份
cleanup_old_backups() {
    echo -e "${YELLOW}将保留最近 3 个备份，删除其余备份${NC}"
    echo -n "确定要继续吗? (yes/no): "
    read confirm
    
    if [ "$confirm" = "yes" ]; then
        local backup_count=$(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l)
        
        if [ "$backup_count" -gt 3 ]; then
            ls -1t "$BACKUP_DIR"/*.tar.gz | tail -n +4 | while read old_backup; do
                echo "删除: $(basename $old_backup)"
                rm -f "$old_backup"
            done
            echo -e "${GREEN}清理完成！${NC}"
        else
            echo -e "${YELLOW}备份数量不超过 3 个，无需清理${NC}"
        fi
    else
        echo "操作已取消"
    fi
    
    echo ""
    read -p "按回车键继续..."
}

# 11. 查看定时任务
view_crontab() {
    echo -e "${BLUE}当前定时任务配置:${NC}"
    echo ""
    crontab -l
    echo ""
    echo -e "${YELLOW}提示: 使用 'crontab -e' 命令可以编辑定时任务${NC}"
    echo ""
    read -p "按回车键继续..."
}

# 12. 测试 SSH 连接
test_ssh() {
    echo -e "${BLUE}测试 GitHub SSH 连接...${NC}"
    echo ""
    ssh -T git@github.com 2>&1
    echo ""
    
    if [ $? -eq 1 ]; then
        echo -e "${GREEN}SSH 连接正常！${NC}"
    else
        echo -e "${RED}SSH 连接失败！${NC}"
        echo -e "${YELLOW}请检查 SSH 密钥配置${NC}"
    fi
    
    echo ""
    read -p "按回车键继续..."
}

# 主循环
while true; do
    clear
    show_menu
    read choice
    
    case $choice in
        1) do_backup ;;
        2) list_backups ;;
        3) view_recent_log ;;
        4) view_full_log ;;
        5) show_stats ;;
        6) check_github_status ;;
        7) push_to_github ;;
        8) pull_from_github ;;
        9) delete_backup ;;
        10) cleanup_old_backups ;;
        11) view_crontab ;;
        12) test_ssh ;;
        0) 
            echo -e "${GREEN}再见！${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}无效的选择${NC}"
            sleep 2
            ;;
    esac
done
