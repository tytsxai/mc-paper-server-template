#!/usr/bin/env bash

set -euo pipefail

# ====================================
# 新人指引自动化脚本
# ====================================
# 此脚本用于向新加入的玩家发送分步教学指引
# 使用 RCON 与服务器通信（依赖 send-command.sh）

DIR="$(cd "$(dirname "$0")" && pwd)"
RCON_SENDER="${RCON_SENDER:-$DIR/send-command.sh}"

if [ ! -x "$RCON_SENDER" ]; then
    echo "错误：未找到 RCON 发送脚本 $RCON_SENDER，请先确保 RCON 已开启且 send-command.sh 可执行。" >&2
    exit 1
fi

# 颜色代码说明：
# &a = 绿色, &b = 青色, &c = 红色, &d = 粉色, &e = 黄色, &f = 白色
# &6 = 金色, &7 = 灰色, &l = 粗体

# 发送 RCON 命令的函数
send_command() {
    local command="$1"
    "$RCON_SENDER" "$command" >/dev/null
}

# 向指定玩家发送消息
send_message() {
    local player="$1"
    local message="$2"
    send_command "tellraw $player {\"text\":\"$message\"}"
}

# 向指定玩家发送标题
send_title() {
    local player="$1"
    local title="$2"
    local subtitle="$3"
    send_command "title $player title {\"text\":\"$title\"}"
    if [ -n "$subtitle" ]; then
        send_command "title $player subtitle {\"text\":\"$subtitle\"}"
    fi
}

# 新人完整教学流程
newbie_tutorial() {
    local player="$1"

    echo "开始为玩家 $player 发送新人指引..."

    # 欢迎消息
    sleep 2
    send_command "tellraw $player {\"text\":\"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\",\"color\":\"gold\",\"bold\":true}"
    sleep 1
    send_command "tellraw $player {\"text\":\"✦ 欢迎来到我们的 Minecraft 服务器！\",\"color\":\"green\",\"bold\":true}"
    sleep 2
    send_command "tellraw $player {\"text\":\"你好，$player！我是服务器的智能助手。\",\"color\":\"yellow\"}"
    sleep 2
    send_command "tellraw $player {\"text\":\"让我来帮助你快速了解服务器的基本功能吧！\",\"color\":\"aqua\"}"
    sleep 2
    send_command "tellraw $player {\"text\":\"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\",\"color\":\"gold\",\"bold\":true}"

    # 第一步：基础命令
    sleep 8
    send_title "$player" "【第一步】基础命令" ""
    sleep 1
    send_command "tellraw $player {\"text\":\"【第一步】基础命令\",\"color\":\"green\",\"bold\":true}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ /spawn - 回到出生点\",\"color\":\"gray\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ /sethome [名称] - 设置家的位置\",\"color\":\"gray\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ /home [名称] - 传送到你的家\",\"color\":\"gray\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ /tpa <玩家名> - 请求传送到其他玩家\",\"color\":\"gray\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ /back - 返回上一个位置\",\"color\":\"gray\"}"

    # 第二步：新手礼包
    sleep 10
    send_title "$player" "【第二步】新手礼包" ""
    sleep 1
    send_command "tellraw $player {\"text\":\"【第二步】新手礼包\",\"color\":\"aqua\",\"bold\":true}"
    sleep 1
    send_command "tellraw $player {\"text\":\"你已经获得了基础工具包！\",\"color\":\"yellow\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"如果需要更多帮助，可以使用：\",\"color\":\"gray\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ /kit welcome - 领取新手礼包（仅一次）\",\"color\":\"gray\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ /kit tools - 领取工具包（冷却10秒）\",\"color\":\"gray\"}"

    # 第三步：保护领地
    sleep 10
    send_title "$player" "【第三步】保护你的领地" ""
    sleep 1
    send_command "tellraw $player {\"text\":\"【第三步】保护你的领地\",\"color\":\"light_purple\",\"bold\":true}"
    sleep 1
    send_command "tellraw $player {\"text\":\"服务器安装了 GriefPrevention 领地保护插件\",\"color\":\"gold\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ 使用金铲子右键点击两个对角来圈地\",\"color\":\"gray\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ /abandonclaim - 删除你所在的领地\",\"color\":\"gray\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ /trust <玩家名> - 信任玩家可以使用你的领地\",\"color\":\"gray\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ /untrust <玩家名> - 取消信任\",\"color\":\"gray\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ /claimslist - 查看你的所有领地\",\"color\":\"gray\"}"

    # 第四步：社交互动
    sleep 10
    send_title "$player" "【第四步】社交与互动" ""
    sleep 1
    send_command "tellraw $player {\"text\":\"【第四步】社交与互动\",\"color\":\"red\",\"bold\":true}"
    sleep 1
    send_command "tellraw $player {\"text\":\"服务器支持多种社交功能：\",\"color\":\"green\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ /msg <玩家名> <消息> - 私聊其他玩家\",\"color\":\"gray\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ /r <消息> - 快速回复上一个私聊\",\"color\":\"gray\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ /sit - 坐下休息\",\"color\":\"gray\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ /lay - 躺下\",\"color\":\"gray\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"加入我们的 QQ 群：539136479\",\"color\":\"yellow\",\"bold\":true}"

    # 第五步：其他功能
    sleep 10
    send_title "$player" "【第五步】其他实用功能" ""
    sleep 1
    send_command "tellraw $player {\"text\":\"【第五步】其他实用功能\",\"color\":\"dark_purple\",\"bold\":true}"
    sleep 1
    send_command "tellraw $player {\"text\":\"更多实用命令：\",\"color\":\"gold\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ /suicide - 自杀（慎用）\",\"color\":\"gray\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ /warp - 查看可用的传送点\",\"color\":\"gray\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ /help - 查看帮助信息\",\"color\":\"gray\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"▸ /rules - 查看服务器规则\",\"color\":\"gray\"}"

    # 完成教程
    sleep 10
    send_title "$player" "【完成】开始你的冒险！" "祝你游戏愉快！"
    sleep 1
    send_command "tellraw $player {\"text\":\"【完成】开始你的冒险！\",\"color\":\"dark_green\",\"bold\":true}"
    sleep 1
    send_command "tellraw $player {\"text\":\"✔ 新手教程已完成！\",\"color\":\"green\",\"bold\":true}"
    sleep 1
    send_command "tellraw $player {\"text\":\"现在你可以开始探索这个世界了！\",\"color\":\"yellow\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"记住：友善待人，遵守规则，享受游戏！\",\"color\":\"aqua\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"如果遇到问题，随时使用 /help 查看帮助\",\"color\":\"light_purple\"}"
    sleep 1
    send_command "tellraw $player {\"text\":\"祝你游戏愉快！ ❤\",\"color\":\"gold\",\"bold\":true}"
    sleep 1
    send_command "tellraw $player {\"text\":\"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\",\"color\":\"gold\",\"bold\":true}"

    echo "新人指引已完成发送给玩家 $player"
}

# 快速帮助命令
quick_help() {
    local player="$1"
    local topic="$2"

    case "$topic" in
        "commands")
            send_command "tellraw $player {\"text\":\"━━━ 基础命令 ━━━\",\"color\":\"aqua\",\"bold\":true}"
            send_command "tellraw $player {\"text\":\"传送命令：\",\"color\":\"yellow\"}"
            send_command "tellraw $player {\"text\":\"▸ /spawn - 回到出生点\",\"color\":\"gray\"}"
            send_command "tellraw $player {\"text\":\"▸ /sethome [名称] - 设置家\",\"color\":\"gray\"}"
            send_command "tellraw $player {\"text\":\"▸ /home [名称] - 回家\",\"color\":\"gray\"}"
            send_command "tellraw $player {\"text\":\"▸ /tpa <玩家> - 请求传送\",\"color\":\"gray\"}"
            send_command "tellraw $player {\"text\":\"▸ /back - 返回上一位置\",\"color\":\"gray\"}"
            ;;
        "claim")
            send_command "tellraw $player {\"text\":\"━━━ 领地保护 ━━━\",\"color\":\"light_purple\",\"bold\":true}"
            send_command "tellraw $player {\"text\":\"如何圈地：\",\"color\":\"yellow\"}"
            send_command "tellraw $player {\"text\":\"1. 手持金铲子\",\"color\":\"gray\"}"
            send_command "tellraw $player {\"text\":\"2. 右键点击第一个角\",\"color\":\"gray\"}"
            send_command "tellraw $player {\"text\":\"3. 右键点击对角位置\",\"color\":\"gray\"}"
            send_command "tellraw $player {\"text\":\"领地命令：\",\"color\":\"yellow\"}"
            send_command "tellraw $player {\"text\":\"▸ /abandonclaim - 删除领地\",\"color\":\"gray\"}"
            send_command "tellraw $player {\"text\":\"▸ /trust <玩家> - 信任玩家\",\"color\":\"gray\"}"
            send_command "tellraw $player {\"text\":\"▸ /claimslist - 查看领地列表\",\"color\":\"gray\"}"
            ;;
        "social")
            send_command "tellraw $player {\"text\":\"━━━ 社交功能 ━━━\",\"color\":\"green\",\"bold\":true}"
            send_command "tellraw $player {\"text\":\"聊天命令：\",\"color\":\"yellow\"}"
            send_command "tellraw $player {\"text\":\"▸ /msg <玩家> <消息> - 私聊\",\"color\":\"gray\"}"
            send_command "tellraw $player {\"text\":\"▸ /r <消息> - 回复私聊\",\"color\":\"gray\"}"
            send_command "tellraw $player {\"text\":\"动作命令：\",\"color\":\"yellow\"}"
            send_command "tellraw $player {\"text\":\"▸ /sit - 坐下\",\"color\":\"gray\"}"
            send_command "tellraw $player {\"text\":\"▸ /lay - 躺下\",\"color\":\"gray\"}"
            send_command "tellraw $player {\"text\":\"加入 QQ 群：539136479\",\"color\":\"aqua\",\"bold\":true}"
            ;;
        *)
            send_command "tellraw $player {\"text\":\"━━━ 新手指引菜单 ━━━\",\"color\":\"gold\",\"bold\":true}"
            send_command "tellraw $player {\"text\":\"1. 基础命令 - 输入 /guide commands\",\"color\":\"green\"}"
            send_command "tellraw $player {\"text\":\"2. 领地保护 - 输入 /guide claim\",\"color\":\"green\"}"
            send_command "tellraw $player {\"text\":\"3. 社交功能 - 输入 /guide social\",\"color\":\"green\"}"
            send_command "tellraw $player {\"text\":\"4. 服务器规则 - 输入 /rules\",\"color\":\"green\"}"
            ;;
    esac
}

# 主函数
main() {
    if [ $# -eq 0 ]; then
        echo "用法: $0 <玩家名> [tutorial|help <主题>]"
        echo "示例："
        echo "  $0 Steve tutorial    # 发送完整新人教程"
        echo "  $0 Steve help        # 显示帮助菜单"
        echo "  $0 Steve help claim  # 显示领地帮助"
        exit 1
    fi

    local player="$1"
    local action="${2:-tutorial}"
    local topic="${3:-}"

    case "$action" in
        "tutorial")
            newbie_tutorial "$player"
            ;;
        "help")
            quick_help "$player" "$topic"
            ;;
        *)
            echo "未知操作: $action"
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
