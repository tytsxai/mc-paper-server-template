#!/bin/bash
# Essentials 重载脚本

echo "正在重载 Essentials 配置..."

# 方法1: 尝试使用 RCON（如果配置了）
if command -v mcrcon &> /dev/null; then
    echo "使用 RCON 重载..."
    mcrcon -p your_rcon_password "essentials reload"
else
    echo "RCON 未配置，请手动在游戏中执行: /essentials reload"
    echo ""
    echo "或者重启服务器："
    echo "  pkill -f paper-1.21.8-60.jar"
    echo "  bash start.sh"
fi

echo ""
echo "配置文件位置："
echo "  - MOTD: plugins/Essentials/motd.txt"
echo "  - 规则: plugins/Essentials/rules.txt"
echo "  - 礼包: plugins/Essentials/kits.yml"
echo "  - 主配置: plugins/Essentials/config.yml"
echo ""
echo "玩家加入时会自动看到欢迎消息！"
