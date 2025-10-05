#!/bin/bash

cd /root/minecraft-server

# 检查是否已经在运行
if pgrep -f "paper.*jar" > /dev/null; then
    echo "错误：Minecraft服务器已经在运行"
    echo "请先使用 ./stop.sh 停止服务器"
    exit 1
fi

# 启动服务器（使用 screen 或 tmux 更好，但这里保持简单）
nohup java -Xms20G -Xmx20G -jar paper-1.21.8-60.jar nogui > server.log 2>&1 &

PID=$!
echo "Minecraft服务器正在启动... (PID: $PID)"
echo "服务器日志: server.log"
echo ""
echo "查看日志: tail -f /root/minecraft-server/server.log"
echo "停止服务器: /root/minecraft-server/stop.sh"
