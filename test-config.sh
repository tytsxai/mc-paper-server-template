#!/bin/bash
# 测试服务器配置和插件功能

echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                                                                   ║"
echo "║              🧪 Minecraft 服务器配置测试                          ║"
echo "║                                                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

# 1. 检查服务器是否运行
echo "【1/7】检查服务器状态..."
PID=$(ps aux | grep "paper.*jar" | grep -v grep | awk '{print $2}')
if [ -z "$PID" ]; then
    echo "❌ 服务器未运行！"
    exit 1
else
    echo "✅ 服务器正在运行 (PID: $PID)"
fi
echo ""

# 2. 检查配置文件是否存在
echo "【2/7】检查配置文件..."
FILES=(
    "/root/minecraft-server/plugins/Essentials/motd.txt"
    "/root/minecraft-server/plugins/Essentials/rules.txt"
    "/root/minecraft-server/plugins/Essentials/kits.yml"
    "/root/minecraft-server/plugins/Essentials/config.yml"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $(basename $file) 存在"
    else
        echo "❌ $(basename $file) 不存在！"
    fi
done
echo ""

# 3. 检查 Essentials 插件是否加载
echo "【3/7】检查 Essentials 插件加载..."
if grep -q "Essentials.*enabled" /root/minecraft-server/logs/latest.log; then
    echo "✅ Essentials 插件已加载"
else
    echo "❌ Essentials 插件未正确加载"
fi
echo ""

# 4. 检查 motd.txt 内容
echo "【4/7】检查欢迎消息内容..."
if grep -q "QQ群" /root/minecraft-server/plugins/Essentials/motd.txt; then
    echo "✅ motd.txt 包含 QQ 群信息"
else
    echo "❌ motd.txt 缺少 QQ 群信息"
fi

if grep -q "kit" /root/minecraft-server/plugins/Essentials/motd.txt; then
    echo "✅ motd.txt 包含礼包信息"
else
    echo "❌ motd.txt 缺少礼包信息"
fi
echo ""

# 5. 检查 kits.yml 配置
echo "【5/7】检查礼包配置..."
KITS=("welcome" "daily" "tools")
for kit in "${KITS[@]}"; do
    if grep -q "^  $kit:" /root/minecraft-server/plugins/Essentials/kits.yml; then
        echo "✅ 礼包 '$kit' 已配置"
    else
        echo "❌ 礼包 '$kit' 未配置"
    fi
done
echo ""

# 6. 检查 config.yml 中的 delay-motd 设置
echo "【6/7】检查 delay-motd 设置..."
if grep -q "delay-motd: 0" /root/minecraft-server/plugins/Essentials/config.yml; then
    echo "✅ delay-motd 已设置为 0（立即显示）"
else
    echo "⚠️  delay-motd 可能未正确设置"
fi
echo ""

# 7. 显示 motd.txt 预览
echo "【7/7】欢迎消息预览（前 20 行）..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
head -20 /root/minecraft-server/plugins/Essentials/motd.txt
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                                                                   ║"
echo "║                    📊 测试总结                                    ║"
echo "║                                                                   ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""
echo "✅ 服务器配置测试完成！"
echo ""
echo "【玩家测试步骤】"
echo ""
echo "1. 加入服务器"
echo "   → 应该立即看到完整的欢迎消息"
echo ""
echo "2. 执行命令: /motd"
echo "   → 应该重新显示欢迎消息"
echo ""
echo "3. 执行命令: /rules"
echo "   → 应该显示服务器规则"
echo ""
echo "4. 执行命令: /kit welcome"
echo "   → 应该获得新手礼包"
echo ""
echo "5. 执行命令: /kit daily"
echo "   → 应该获得每日签到礼包"
echo ""
echo "6. 执行命令: /kit tools"
echo "   → 应该获得工具礼包"
echo ""
echo "【验证要点】"
echo ""
echo "✦ 所有消息都应该包含 QQ 群号：539136479"
echo "✦ 欢迎消息应该包含所有插件功能说明"
echo "✦ 礼包应该能够正常领取"
echo "✦ 新玩家首次加入应该有全服广播"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
