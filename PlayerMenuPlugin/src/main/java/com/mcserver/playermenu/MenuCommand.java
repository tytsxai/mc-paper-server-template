package com.mcserver.playermenu;

import org.bukkit.command.Command;
import org.bukkit.command.CommandExecutor;
import org.bukkit.command.CommandSender;
import org.bukkit.entity.Player;

public class MenuCommand implements CommandExecutor {

    @Override
    public boolean onCommand(CommandSender sender, Command command, String label, String[] args) {
        if (!(sender instanceof Player)) {
            sender.sendMessage("§c只有玩家可以使用此命令！");
            return true;
        }

        Player player = (Player) sender;

        // 检查是否有参数
        if (args.length > 0) {
            String subCommand = args[0].toLowerCase();

            switch (subCommand) {
                case "toggle":
                case "切换":
                    // 切换菜单物品显示
                    MenuItemManager.toggleMenuItem(player);
                    return true;

                case "on":
                case "开启":
                case "enable":
                    // 启用菜单物品
                    MenuItemManager.enableMenuItem(player);
                    return true;

                case "off":
                case "关闭":
                case "disable":
                    // 禁用菜单物品
                    MenuItemManager.disableMenuItem(player);
                    return true;

                case "get":
                case "获取":
                    // 重新获取菜单物品
                    if (MenuItemManager.isEnabled(player)) {
                        MenuItemManager.giveMenuItem(player);
                        player.sendMessage("§a已重新获取菜单物品");
                    } else {
                        player.sendMessage("§c请先启用菜单物品: §f/menu on");
                    }
                    return true;

                case "help":
                case "帮助":
                    // 显示帮助信息
                    showHelp(player);
                    return true;

                default:
                    player.sendMessage("§c未知参数: " + args[0]);
                    showHelp(player);
                    return true;
            }
        }

        // 无参数，打开主菜单
        MenuManager.openMainMenu(player);

        return true;
    }

    private void showHelp(Player player) {
        player.sendMessage("§6§l╔═══════════════════════════════╗");
        player.sendMessage("§6§l║  菜单系统使用帮助            ║");
        player.sendMessage("§6§l╚═══════════════════════════════╝");
        player.sendMessage("");
        player.sendMessage("§a基础命令:");
        player.sendMessage("  §f/menu §7- 打开菜单");
        player.sendMessage("  §f/菜单 §7- 打开菜单");
        player.sendMessage("  §f/mm §7- 打开菜单");
        player.sendMessage("");
        player.sendMessage("§a菜单物品管理:");
        player.sendMessage("  §f/menu toggle §7- 开关菜单物品");
        player.sendMessage("  §f/menu on §7- 启用菜单物品");
        player.sendMessage("  §f/menu off §7- 禁用菜单物品");
        player.sendMessage("  §f/menu get §7- 重新获取菜单物品");
        player.sendMessage("");
        player.sendMessage("§e提示: §7菜单物品会固定在快捷栏");
        player.sendMessage("§e提示: §7右键点击菜单物品即可打开菜单");
    }
}
