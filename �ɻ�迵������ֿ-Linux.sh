#!/usr/bin/env bash

# ============================================================
#  Minecraft Paper 1.21.8 服务器启动脚本
#  优化配置：Intel Xeon Gold 6138 (12核) / 24GB RAM
#  目标：80人在线 / 困难模式
# ============================================================

# 确保中文显示
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8

# 切换到脚本所在目录
cd "$(dirname "$0")"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================${NC}"
echo -e "${GREEN}  🎮 Minecraft Paper 服务器启动脚本${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""
echo -e "${YELLOW}📊 服务器硬件配置:${NC}"
echo "  • CPU: Intel Xeon Gold 6138 (12核心 @ 2.0GHz)"
echo "  • RAM: 24 GB"
echo "  • OS:  Debian GNU/Linux 13 (trixie)"
echo "  • 磁盘: 75 GB (68 GB 可用)"
echo ""
echo -e "${YELLOW}🎯 服务器设置:${NC}"
echo "  • 最大玩家: 80 人"
echo "  • 游戏难度: 困难 (HARD)"
echo "  • 游戏模式: 生存"
echo ""

# ============================================================
# 内存配置 - 针对 24GB RAM 优化
# ============================================================
# 推荐配置：为 80 人服务器分配 18GB
# 保留 6GB 给系统和其他进程
# ============================================================

XMS=6G    # 初始内存：6GB（避免频繁GC）
XMX=18G   # 最大内存：18GB（为系统保留6GB）

echo -e "${GREEN}⚙️  内存分配:${NC}"
echo "  • 初始内存 (Xms): ${XMS}"
echo "  • 最大内存 (Xmx): ${XMX}"
echo "  • 系统保留: 6GB"
echo ""

# ============================================================
# JVM 优化参数 - Aikar's Flags (针对 Paper 优化)
# ============================================================
# 这些参数专为 Minecraft 服务器优化，可显著提升性能
# 参考: https://docs.papermc.io/paper/aikars-flags
# ============================================================

JAVA_OPTS="
-Xms${XMS}
-Xmx${XMX}
-XX:+UseG1GC
-XX:+ParallelRefProcEnabled
-XX:MaxGCPauseMillis=200
-XX:+UnlockExperimentalVMOptions
-XX:+DisableExplicitGC
-XX:+AlwaysPreTouch
-XX:G1NewSizePercent=30
-XX:G1MaxNewSizePercent=40
-XX:G1HeapRegionSize=8M
-XX:G1ReservePercent=20
-XX:G1HeapWastePercent=5
-XX:G1MixedGCCountTarget=4
-XX:InitiatingHeapOccupancyPercent=15
-XX:G1MixedGCLiveThresholdPercent=90
-XX:G1RSetUpdatingPauseTimePercent=5
-XX:SurvivorRatio=32
-XX:+PerfDisableSharedMem
-XX:MaxTenuringThreshold=1
-Dusing.aikars.flags=https://mcflags.emc.gs
-Daikars.new.flags=true
-Dfile.encoding=UTF-8
-Djava.net.preferIPv4Stack=true
"

echo -e "${BLUE}🚀 JVM 优化参数已启用 (Aikar's Flags)${NC}"
echo "  • G1GC 垃圾回收器"
echo "  • 并行引用处理"
echo "  • 最大 GC 暂停: 200ms"
echo "  • 针对大型服务器优化"
echo ""

# ============================================================
# 检查 Java 版本
# ============================================================
echo -e "${YELLOW}🔍 检查 Java 环境...${NC}"

if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    echo -e "${GREEN}✓ Java 版本: ${JAVA_VERSION}${NC}"

    # 检查是否为 Java 21+（Paper 1.21.8 需要）
    JAVA_MAJOR=$(echo $JAVA_VERSION | cut -d'.' -f1)
    if [ "$JAVA_MAJOR" -lt 21 ]; then
        echo -e "${RED}⚠️  警告: Paper 1.21.8 需要 Java 21 或更高版本${NC}"
        echo -e "${RED}   当前版本: ${JAVA_VERSION}${NC}"
        echo ""
        read -p "是否继续启动？(y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
else
    echo -e "${RED}✗ 未找到 Java！请先安装 Java 21+${NC}"
    exit 1
fi

echo ""

# ============================================================
# 检查 eula.txt
# ============================================================
if [ ! -f "eula.txt" ]; then
    echo -e "${YELLOW}⚠️  首次启动检测${NC}"
    echo "请确认你已阅读并同意 Minecraft EULA"
    echo "https://aka.ms/MinecraftEULA"
    echo ""
fi

# ============================================================
# 启动服务器
# ============================================================
echo -e "${BLUE}============================================================${NC}"
echo -e "${GREEN}🎮 正在启动服务器...${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""
echo -e "${YELLOW}💡 提示:${NC}"
echo "  • 使用 'stop' 命令安全关闭服务器"
echo "  • 使用 'Ctrl+C' 可能导致数据丢失"
echo "  • 首次启动后，在控制台输入: gamerule mobGriefing true"
echo ""
echo -e "${BLUE}============================================================${NC}"
echo ""

# 启动服务器（移除 exec 以便脚本可以捕获退出状态）
java $JAVA_OPTS -jar paper-1.21.8-60.jar nogui

# ============================================================
# 服务器关闭后的处理
# ============================================================
EXIT_CODE=$?
echo ""
echo -e "${BLUE}============================================================${NC}"
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ 服务器已正常关闭${NC}"
else
    echo -e "${RED}✗ 服务器异常退出 (退出码: ${EXIT_CODE})${NC}"
fi
echo -e "${BLUE}============================================================${NC}"

exit $EXIT_CODE
