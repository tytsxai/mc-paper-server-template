#!/usr/bin/env bash

# ============================================================
# Debian 系统优化脚本 - 针对 Minecraft 服务器
# 适用于：Debian GNU/Linux 13 (trixie)
# 硬件：Intel Xeon Gold 6138 (12核) / 24GB RAM
# ============================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================${NC}"
echo -e "${GREEN}  🔧 Minecraft 服务器系统优化脚本${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}✗ 请使用 root 权限运行此脚本${NC}"
    echo -e "${YELLOW}  使用: sudo ./系统优化脚本.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Root 权限确认${NC}"
echo ""

# ============================================================
# 1. 创建交换空间（Swap）
# ============================================================
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📝 步骤 1/5: 配置交换空间${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ -f /swapfile ]; then
    echo -e "${YELLOW}⚠️  交换文件已存在，跳过创建${NC}"
else
    echo -e "${GREEN}→ 创建 4GB 交换文件...${NC}"

    # 创建交换文件
    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile

    # 添加到 fstab 以便开机自动挂载
    if ! grep -q '/swapfile' /etc/fstab; then
        echo '/swapfile none swap sw 0 0' >> /etc/fstab
        echo -e "${GREEN}✓ 交换空间已添加到 /etc/fstab${NC}"
    fi

    # 设置 swappiness（降低使用交换空间的倾向）
    sysctl vm.swappiness=10
    echo 'vm.swappiness=10' >> /etc/sysctl.conf

    echo -e "${GREEN}✓ 交换空间配置完成 (4GB)${NC}"
fi

echo ""
echo -e "${GREEN}当前交换空间状态:${NC}"
free -h | grep -E "Swap|交换"
echo ""

# ============================================================
# 2. 网络优化
# ============================================================
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📝 步骤 2/5: 网络优化${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${GREEN}→ 配置网络参数...${NC}"

# 备份原始配置
if [ ! -f /etc/sysctl.conf.backup ]; then
    cp /etc/sysctl.conf /etc/sysctl.conf.backup
    echo -e "${GREEN}✓ 已备份原始配置到 /etc/sysctl.conf.backup${NC}"
fi

# 添加网络优化参数
cat >> /etc/sysctl.conf << 'EOF'

# ============================================================
# Minecraft 服务器网络优化
# 添加时间: $(date)
# ============================================================

# TCP 缓冲区优化
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864

# 连接队列优化
net.core.somaxconn = 4096
net.core.netdev_max_backlog = 5000

# TCP 优化
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_tw_reuse = 1

# 文件描述符限制
fs.file-max = 2097152

EOF

# 应用配置
sysctl -p > /dev/null 2>&1

echo -e "${GREEN}✓ 网络优化配置完成${NC}"
echo ""

# ============================================================
# 3. 系统限制优化
# ============================================================
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📝 步骤 3/5: 系统限制优化${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${GREEN}→ 配置系统限制...${NC}"

# 备份原始配置
if [ ! -f /etc/security/limits.conf.backup ]; then
    cp /etc/security/limits.conf /etc/security/limits.conf.backup
    echo -e "${GREEN}✓ 已备份原始配置到 /etc/security/limits.conf.backup${NC}"
fi

# 添加限制配置
cat >> /etc/security/limits.conf << 'EOF'

# ============================================================
# Minecraft 服务器系统限制优化
# ============================================================

# 文件描述符限制
*               soft    nofile          65536
*               hard    nofile          65536

# 进程数限制
*               soft    nproc           32768
*               hard    nproc           32768

EOF

echo -e "${GREEN}✓ 系统限制配置完成${NC}"
echo ""

# ============================================================
# 4. 防火墙配置
# ============================================================
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📝 步骤 4/5: 防火墙配置${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 检查是否安装了 ufw
if command -v ufw &> /dev/null; then
    echo -e "${GREEN}→ 配置 UFW 防火墙...${NC}"

    # 允许 SSH（防止被锁定）
    ufw allow 22/tcp comment 'SSH'

    # 允许 Minecraft 默认端口
    ufw allow 25565/tcp comment 'Minecraft Server'

    echo -e "${GREEN}✓ 防火墙规则已添加${NC}"
    echo -e "${YELLOW}⚠️  注意：请手动执行 'ufw enable' 启用防火墙${NC}"
    echo -e "${YELLOW}   （确保 SSH 连接正常后再启用）${NC}"
else
    echo -e "${YELLOW}⚠️  未检测到 UFW，跳过防火墙配置${NC}"
    echo -e "${YELLOW}   如需安装: apt install ufw${NC}"
fi

echo ""

# ============================================================
# 5. 创建自动备份脚本
# ============================================================
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📝 步骤 5/5: 创建自动备份脚本${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 获取当前脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 创建备份脚本
cat > "${SCRIPT_DIR}/自动备份.sh" << 'EOF'
#!/usr/bin/env bash

# ============================================================
# Minecraft 服务器自动备份脚本
# ============================================================

# 配置
BACKUP_DIR="/root/minecraft_backups"
SERVER_DIR="$(cd "$(dirname "$0")" && pwd)"
MAX_BACKUPS=7  # 保留最近 7 天的备份

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 备份文件名（包含日期）
BACKUP_NAME="minecraft_backup_$(date +%Y%m%d_%H%M%S).tar.gz"

echo "开始备份..."
echo "服务器目录: $SERVER_DIR"
echo "备份目录: $BACKUP_DIR"
echo ""

# 创建备份（排除不必要的文件）
cd "$SERVER_DIR"
tar -czf "$BACKUP_DIR/$BACKUP_NAME" \
    --exclude='*.jar' \
    --exclude='cache' \
    --exclude='logs' \
    world world_nether world_the_end \
    server.properties bukkit.yml spigot.yml \
    config plugins 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ 备份完成: $BACKUP_NAME"

    # 显示备份大小
    BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_NAME" | cut -f1)
    echo "  备份大小: $BACKUP_SIZE"

    # 删除旧备份（保留最近的 MAX_BACKUPS 个）
    cd "$BACKUP_DIR"
    ls -t minecraft_backup_*.tar.gz | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm

    echo "✓ 已清理旧备份（保留最近 $MAX_BACKUPS 个）"
    echo ""
    echo "当前备份列表:"
    ls -lh minecraft_backup_*.tar.gz 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
else
    echo "✗ 备份失败"
    exit 1
fi
EOF

chmod +x "${SCRIPT_DIR}/自动备份.sh"

echo -e "${GREEN}✓ 备份脚本已创建: ${SCRIPT_DIR}/自动备份.sh${NC}"
echo ""
echo -e "${YELLOW}💡 设置定时备份（可选）:${NC}"
echo -e "   1. 编辑 crontab: ${BLUE}crontab -e${NC}"
echo -e "   2. 添加以下行（每天凌晨 4 点备份）:"
echo -e "      ${GREEN}0 4 * * * ${SCRIPT_DIR}/自动备份.sh >> ${SCRIPT_DIR}/backup.log 2>&1${NC}"
echo ""

# ============================================================
# 优化完成总结
# ============================================================
echo -e "${BLUE}============================================================${NC}"
echo -e "${GREEN}  ✅ 系统优化完成！${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""
echo -e "${GREEN}已完成的优化:${NC}"
echo -e "  ✓ 交换空间: 4GB (swappiness=10)"
echo -e "  ✓ 网络优化: TCP 缓冲区和连接队列"
echo -e "  ✓ 系统限制: 文件描述符和进程数"
echo -e "  ✓ 防火墙规则: SSH + Minecraft 端口"
echo -e "  ✓ 备份脚本: 自动备份.sh"
echo ""
echo -e "${YELLOW}⚠️  重要提示:${NC}"
echo -e "  1. 部分优化需要重启系统才能完全生效"
echo -e "  2. 如果配置了防火墙，请确保 SSH 连接正常后再启用"
echo -e "  3. 建议设置定时备份任务"
echo ""
echo -e "${BLUE}============================================================${NC}"
echo -e "${GREEN}  现在可以启动 Minecraft 服务器了！${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""
echo -e "执行: ${GREEN}./启动服务器-Linux.sh${NC}"
echo ""
