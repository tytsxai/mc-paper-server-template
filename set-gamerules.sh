#!/bin/bash

# 等待服务器完全启动
echo "等待服务器启动..."
sleep 30

# 使用RCON设置游戏规则
echo "设置游戏规则..."

# 确保生物能破坏方块（苦力怕爆炸、末影人搬方块等）
mcrcon -H localhost -P 25575 -p admin123 "gamerule mobGriefing true"

# 设置难度为困难
mcrcon -H localhost -P 25575 -p admin123 "difficulty hard"

# 显示当前游戏规则
echo "当前游戏规则："
mcrcon -H localhost -P 25575 -p admin123 "gamerule mobGriefing"
mcrcon -H localhost -P 25575 -p admin123 "difficulty"

echo "游戏规则设置完成！"
echo ""
echo "重要配置说明："
echo "- mobGriefing = true: 苦力怕可以炸毁方块，末影人可以搬运方块"
echo "- difficulty = hard: 困难模式"
