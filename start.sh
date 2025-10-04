#!/bin/bash
# Minecraft Paper Server 启动脚本

cd "$(dirname "$0")"

# 检查 Java 版本
if ! command -v java &> /dev/null; then
    echo "错误: 未找到 Java。请安装 Java 21 或更高版本。"
    exit 1
fi

# 启动服务器
# 可以根据需要调整内存参数 -Xms (最小内存) 和 -Xmx (最大内存)
java -Xms2G -Xmx4G -jar paper-1.21.8-60.jar nogui
