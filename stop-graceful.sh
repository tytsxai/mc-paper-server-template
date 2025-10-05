#!/bin/bash

# 优雅停止服务器（通过 RCON 发送 stop 命令）

cd /root/minecraft-server

# 检查服务器是否在运行
PID=$(ps aux | grep "paper.*jar" | grep -v grep | awk '{print $2}')

if [ -z "$PID" ]; then
    echo "Minecraft服务器未运行"
    exit 0
fi

echo "正在通过 RCON 发送停止命令..."

# 尝试通过 send-command.sh 发送 stop 命令
if [ -f "send-command.sh" ]; then
    bash send-command.sh "stop" 2>/dev/null
    echo "已发送 stop 命令，等待服务器关闭..."
else
    echo "未找到 send-command.sh，使用 kill 信号..."
    kill $PID
fi

# 等待最多 75 秒
for i in {1..75}; do
    if ! ps -p $PID > /dev/null 2>&1; then
        echo "服务器已正常停止"
        exit 0
    fi
    sleep 1
    if [ $((i % 10)) -eq 0 ]; then
        echo "等待中... ($i/75秒)"
    fi
done

echo ""
echo "警告：服务器在75秒内未停止，可能卡在 I/O pool 关闭"
echo "这是 Paper 的已知问题，将强制终止..."
kill -9 $PID
sleep 2

if ! ps -p $PID > /dev/null 2>&1; then
    echo "服务器已强制停止"
else
    echo "错误：无法停止服务器进程"
    exit 1
fi
