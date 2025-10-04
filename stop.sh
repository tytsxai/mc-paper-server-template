#!/bin/bash
# Minecraft Paper Server 停止脚本

echo "正在停止 Minecraft 服务器..."
pkill -f "paper-1.21.8-60.jar"

# 等待进程完全停止
sleep 3

# 检查是否成功停止
if pgrep -f "paper-1.21.8-60.jar" > /dev/null; then
    echo "警告: 服务器进程仍在运行"
    echo "尝试强制停止..."
    pkill -9 -f "paper-1.21.8-60.jar"
else
    echo "服务器已成功停止"
fi
