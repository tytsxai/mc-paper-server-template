#!/bin/bash

###############################################################################
# Minecraft 服务器强制推送脚本
# 功能：将本地所有内容强制推送到 GitHub，完全以本地为主
# 特点：不进行任何拉取操作，防止远程仓库污染本地
###############################################################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Minecraft 服务器强制推送脚本${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 1. 检查是否在 Git 仓库中
echo -e "${YELLOW}[1/8] 检查 Git 仓库状态...${NC}"
if [ ! -d ".git" ]; then
    echo -e "${RED}错误：当前目录不是 Git 仓库！${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Git 仓库检查通过${NC}"
echo ""

# 2. 显示远程仓库信息
echo -e "${YELLOW}[2/8] 远程仓库信息：${NC}"
git remote -v
echo ""

# 3. 显示当前分支
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${YELLOW}[3/8] 当前分支：${NC}${GREEN}$CURRENT_BRANCH${NC}"
echo ""

# 4. 备份当前状态（创建本地标签）
BACKUP_TAG="backup-before-push-$(date +%Y%m%d-%H%M%S)"
echo -e "${YELLOW}[4/8] 创建本地备份标签：${NC}$BACKUP_TAG"
git tag -f "$BACKUP_TAG" 2>/dev/null || true
echo -e "${GREEN}✓ 备份标签已创建（如需恢复：git reset --hard $BACKUP_TAG）${NC}"
echo ""

# 5. 添加所有更改
echo -e "${YELLOW}[5/8] 添加所有文件到暂存区...${NC}"
git add -A
echo -e "${GREEN}✓ 所有文件已添加${NC}"
echo ""

# 6. 显示将要提交的内容
echo -e "${YELLOW}[6/8] 将要提交的内容：${NC}"
git status --short | head -20
TOTAL_CHANGES=$(git status --short | wc -l)
if [ "$TOTAL_CHANGES" -gt 20 ]; then
    echo -e "${BLUE}... 还有 $((TOTAL_CHANGES - 20)) 个文件未显示${NC}"
fi
echo ""

# 7. 提交更改
COMMIT_MSG="服务器完整备份 - $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "${YELLOW}[7/8] 提交更改...${NC}"
echo -e "提交信息：${BLUE}$COMMIT_MSG${NC}"

if git diff --cached --quiet; then
    echo -e "${GREEN}✓ 没有新的更改需要提交${NC}"
else
    git commit -m "$COMMIT_MSG"
    echo -e "${GREEN}✓ 提交成功${NC}"
fi
echo ""

# 8. 强制推送到远程仓库
echo -e "${YELLOW}[8/8] 强制推送到远程仓库...${NC}"
echo -e "${RED}警告：即将执行强制推送，远程仓库将被本地内容完全覆盖！${NC}"
echo -e "${YELLOW}推送目标：origin/$CURRENT_BRANCH${NC}"
echo ""
echo -e "${YELLOW}按 Enter 继续，或按 Ctrl+C 取消...${NC}"
read -r

echo -e "${BLUE}正在推送...${NC}"
git push --force origin "$CURRENT_BRANCH"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✓ 推送完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}推送信息：${NC}"
echo -e "  - 分支：${GREEN}$CURRENT_BRANCH${NC}"
echo -e "  - 远程：${GREEN}origin${NC}"
echo -e "  - 方式：${YELLOW}强制推送（--force）${NC}"
echo -e "  - 备份标签：${GREEN}$BACKUP_TAG${NC}"
echo ""
echo -e "${BLUE}如需恢复到推送前的状态：${NC}"
echo -e "  ${YELLOW}git reset --hard $BACKUP_TAG${NC}"
echo ""
echo -e "${GREEN}✓ 所有操作完成！${NC}"
