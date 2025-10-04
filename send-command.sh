#!/bin/bash
# 向运行中的 Minecraft 服务器发送命令

# 获取服务器进程 PID
PID=$(ps aux | grep "paper.*jar" | grep -v grep | awk '{print $2}')

if [ -z "$PID" ]; then
    echo "错误: 服务器未运行"
    exit 1
fi

# 查找服务器的标准输入
# 由于服务器是用 nogui 模式启动的，我们需要使用 RCON 或重启服务器

echo "服务器正在运行 (PID: $PID)"
echo ""
echo "由于服务器没有使用 screen/tmux，无法直接发送命令。"
echo ""
echo "要使配置生效，有以下几个选择："
echo ""
echo "1. 在游戏中以管理员身份执行: /essentials reload"
echo "2. 使用 RCON 工具（如果已配置）"
echo "3. 重启服务器（会短暂中断玩家连接）"
echo ""
echo "推荐方法 1：在游戏中执行 /essentials reload"
