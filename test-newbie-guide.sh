#!/bin/bash

# ====================================
# 新人指引系统测试脚本
# ====================================

echo "=================================="
echo "  新人指引系统测试"
echo "=================================="
echo ""

# 检查配置文件
echo "1. 检查配置文件..."
files=(
    "新人指引配置.yml"
    "plugins/Essentials/welcome.txt"
    "plugins/Essentials/rules.txt"
    "plugins/Essentials/messages/newbie_guide_cn.txt"
    "newbie-guide.sh"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✓ $file 存在"
    else
        echo "   ✗ $file 不存在"
    fi
done

echo ""
echo "2. 检查脚本权限..."
if [ -x "newbie-guide.sh" ]; then
    echo "   ✓ newbie-guide.sh 有执行权限"
else
    echo "   ✗ newbie-guide.sh 没有执行权限"
    echo "   正在添加执行权限..."
    chmod +x newbie-guide.sh
fi

echo ""
echo "3. 检查 ClearLag 配置..."
if grep -q "autoremoval-interval: 1800" plugins/ClearLag/config.yml; then
    echo "   ✓ 实体清理间隔已设置为 1800 秒（30分钟）"
else
    echo "   ✗ 实体清理间隔配置可能不正确"
fi

echo ""
echo "4. 检查 Essentials 新人配置..."
if grep -q "spawnpoint: newbies" plugins/Essentials/config.yml; then
    echo "   ✓ 新人出生点已配置"
else
    echo "   ⚠ 新人出生点未配置"
fi

if grep -q "kit: tools" plugins/Essentials/config.yml; then
    echo "   ✓ 新人礼包已配置"
else
    echo "   ⚠ 新人礼包未配置"
fi

echo ""
echo "=================================="
echo "  配置检查完成！"
echo "=================================="
echo ""
echo "使用方法："
echo "  1. 测试新人教程："
echo "     ./newbie-guide.sh <玩家名> tutorial"
echo ""
echo "  2. 测试帮助系统："
echo "     ./newbie-guide.sh <玩家名> help"
echo "     ./newbie-guide.sh <玩家名> help commands"
echo "     ./newbie-guide.sh <玩家名> help claim"
echo "     ./newbie-guide.sh <玩家名> help social"
echo ""
echo "  3. 在游戏中测试："
echo "     /motd          - 查看欢迎消息"
echo "     /rules         - 查看服务器规则"
echo "     /kit welcome   - 领取新手礼包"
echo "     /kit tools     - 领取工具包"
echo ""
echo "  4. 重载配置："
echo "     /essentials reload  - 重载 Essentials"
echo "     /lagg reload        - 重载 ClearLag"
echo ""
echo "=================================="
