#!/bin/bash

# 查找并停止Minecraft服务器进程
PID=$(ps aux | grep "paper.*jar" | grep -v grep | awk '{print $2}')

if [ -z "$PID" ]; then
    echo "Minecraft服务器未运行"
else
    echo "正在停止Minecraft服务器 (PID: $PID)..."
    kill $PID

    # 等待最多 70 秒（60秒超时 + 10秒缓冲）
    echo "等待服务器正常关闭（最多70秒）..."
    for i in {1..70}; do
        if ! ps -p $PID > /dev/null 2>&1; then
            echo "服务器已正常停止"
            exit 0
        fi
        sleep 1
        echo -n "."
    done

    echo ""
    echo "服务器未在70秒内停止，强制终止..."
    kill -9 $PID
    sleep 2

    if ! ps -p $PID > /dev/null 2>&1; then
        echo "服务器已强制停止"
    else
        echo "警告：无法停止服务器进程"
    fi
fi
