#!/bin/bash
# 重启 Minecraft 服务器以使配置生效

echo "================================================"
echo "  重启 Minecraft 服务器"
echo "================================================"
echo ""
echo "警告: 这将断开所有在线玩家的连接！"
echo ""
read -p "确定要继续吗？(输入 yes 继续): " confirm

if [ "$confirm" != "yes" ]; then
    echo "已取消重启"
    exit 0
fi

echo ""
echo "正在停止服务器..."

# 获取服务器进程 PID
PID=$(ps aux | grep "paper.*jar" | grep -v grep | awk '{print $2}')

if [ -z "$PID" ]; then
    echo "服务器未运行"
else
    echo "找到服务器进程 (PID: $PID)"
    kill $PID

    # 等待服务器完全停止
    echo "等待服务器完全停止..."
    sleep 5

    # 检查是否还在运行
    if ps -p $PID > /dev/null 2>&1; then
        echo "服务器仍在运行，强制停止..."
        kill -9 $PID
        sleep 2
    fi
fi

echo ""
echo "服务器已停止"
echo ""
echo "正在启动服务器..."
echo ""

cd /root/minecraft-server

# 使用 nohup 在后台启动服务器
nohup java -Xms2G -Xmx4G -jar paper-1.21.8-60.jar nogui > /dev/null 2>&1 &

echo "服务器正在启动..."
echo "请等待 30-60 秒让服务器完全启动"
echo ""
echo "查看启动日志："
echo "  tail -f /root/minecraft-server/logs/latest.log"
echo ""
echo "================================================"
echo "  重启完成！"
echo "================================================"
