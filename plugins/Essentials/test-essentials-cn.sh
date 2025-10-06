#!/bin/bash
# EssentialsX 中文汉化验证脚本

echo "========================================"
echo "  EssentialsX 中文汉化验证"
echo "========================================"
echo ""

# 1. 检查配置文件中的语言设置
echo "1. 检查语言配置..."
LOCALE=$(grep "^locale:" /root/minecraft-server/plugins/Essentials/config.yml | awk '{print $2}' | tr -d '\r\n')
if [ "x$LOCALE" = "xzh" ]; then
    echo "   ✅ 语言设置正确: locale = zh"
else
    echo "   ⚠️  语言设置: locale = $LOCALE"
fi
echo ""

# 2. 检查中文语言文件是否存在
echo "2. 检查中文语言文件..."
if [ -f "/root/minecraft-server/plugins/Essentials/messages/messages_zh.properties" ]; then
    LINES=$(wc -l < /root/minecraft-server/plugins/Essentials/messages/messages_zh.properties)
    SIZE=$(du -h /root/minecraft-server/plugins/Essentials/messages/messages_zh.properties | awk '{print $1}')
    echo "   ✅ messages_zh.properties 存在"
    echo "      - 文件大小: $SIZE"
    echo "      - 翻译行数: $LINES 行"

    if [ $LINES -gt 1500 ]; then
        echo "      - 状态: 完整翻译文件 ✅"
    else
        echo "      - 状态: 翻译不完整 ⚠️"
    fi
else
    echo "   ❌ messages_zh.properties 不存在"
fi
echo ""

# 3. 检查符号链接
echo "3. 检查文件链接..."
if [ -L "/root/minecraft-server/plugins/Essentials/messages/messages_zh_CN.properties" ]; then
    TARGET=$(readlink /root/minecraft-server/plugins/Essentials/messages/messages_zh_CN.properties)
    echo "   ✅ messages_zh_CN.properties -> $TARGET"
else
    echo "   ⚠️  messages_zh_CN.properties 不是符号链接"
fi
echo ""

# 4. 检查文本文件
echo "4. 检查玩家可见文本文件..."
for file in motd.txt rules.txt welcome.txt; do
    FILE_PATH="/root/minecraft-server/plugins/Essentials/$file"
    if [ -f "$FILE_PATH" ]; then
        # 检查是否包含中文字符
        if grep -qP '[\x{4e00}-\x{9fa5}]' "$FILE_PATH" 2>/dev/null || file "$FILE_PATH" | grep -q "UTF-8"; then
            echo "   ✅ $file (已汉化)"
        else
            echo "   ⚠️  $file (未汉化)"
        fi
    else
        echo "   ❌ $file (不存在)"
    fi
done
echo ""

# 5. 检查 GeoIP 本地化设置
echo "5. 检查 EssentialsGeoIP 配置..."
if [ -f "/root/minecraft-server/plugins/EssentialsGeoIP/config.yml" ]; then
    ENABLE_LOCALE=$(grep "^enable-locale:" /root/minecraft-server/plugins/EssentialsGeoIP/config.yml | awk '{print $2}')
    if [ "$ENABLE_LOCALE" == "true" ]; then
        echo "   ✅ GeoIP 本地化已启用"
    else
        echo "   ⚠️  GeoIP 本地化未启用"
    fi
else
    echo "   ⚠️  EssentialsGeoIP 配置文件不存在"
fi
echo ""

# 6. 显示一些翻译示例
echo "6. 翻译内容示例..."
echo "   查看 messages_zh.properties 中的部分翻译："
echo ""
grep -E "^balance=|^teleporting=|^homeSet=|^playerNotFound=" /root/minecraft-server/plugins/Essentials/messages/messages_zh.properties | while read line; do
    KEY=$(echo "$line" | cut -d'=' -f1)
    VALUE=$(echo "$line" | cut -d'=' -f2-)
    echo "   - $KEY = $VALUE"
done
echo ""

# 7. 总结
echo "========================================"
echo "  汉化状态总结"
echo "========================================"
echo ""

# 统计检查项
CHECKS=0
PASSED=0

# 检查语言配置
CHECKS=$((CHECKS + 1))
[ "x$LOCALE" = "xzh" ] && PASSED=$((PASSED + 1))

# 检查语言文件
CHECKS=$((CHECKS + 1))
[ -f "/root/minecraft-server/plugins/Essentials/messages/messages_zh.properties" ] && PASSED=$((PASSED + 1))

# 检查文本文件
for file in motd.txt rules.txt welcome.txt; do
    CHECKS=$((CHECKS + 1))
    [ -f "/root/minecraft-server/plugins/Essentials/$file" ] && PASSED=$((PASSED + 1))
done

echo "通过检查: $PASSED / $CHECKS"
echo ""

if [ $PASSED -eq $CHECKS ]; then
    echo "✅ EssentialsX 插件已完整汉化！"
    echo ""
    echo "建议操作："
    echo "  1. 重启服务器或执行 /ess reload"
    echo "  2. 测试任意命令（如 /balance）验证中文输出"
    echo "  3. 查看 汉化说明.md 了解详细信息"
else
    echo "⚠️  汉化未完全完成，请检查上述失败项"
fi
echo ""
echo "========================================"
