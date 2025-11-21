package com.mcserver.playermenu;

import org.bukkit.Material;
import org.bukkit.entity.Player;
import org.bukkit.inventory.ItemStack;
import org.bukkit.inventory.meta.ItemMeta;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

/**
 * 管理菜单物品（快捷栏中的菜单入口）
 */
public class MenuItemManager {

    // 存储已启用菜单物品的玩家UUID
    private static final Set<UUID> enabledPlayers = new HashSet<>();

    // 菜单物品的固定槽位（默认第9格，即最右边）
    private static final int MENU_ITEM_SLOT = 8;

    /**
     * 创建菜单物品
     */
    public static ItemStack createMenuItem() {
        ItemStack item = new ItemStack(Material.NETHER_STAR);
        ItemMeta meta = item.getItemMeta();

        meta.setDisplayName("§6§l✦ §e§l打开菜单 §6§l✦");
        meta.setLore(Arrays.asList(
            "",
            "§7右键点击打开玩家菜单",
            "§8快速访问所有服务器功能",
            "",
            "§e§l➤ 点击使用",
            ""
        ));

        // 设置为不可破坏、不可掉落的特殊物品
        meta.setUnbreakable(true);

        item.setItemMeta(meta);
        return item;
    }

    /**
     * 检查物品是否是菜单物品
     */
    public static boolean isMenuItem(ItemStack item) {
        if (item == null || item.getType() != Material.NETHER_STAR) {
            return false;
        }

        if (!item.hasItemMeta()) {
            return false;
        }

        ItemMeta meta = item.getItemMeta();
        String displayName = meta.getDisplayName();

        return displayName != null && displayName.contains("打开菜单");
    }

    /**
     * 给玩家菜单物品
     */
    public static void giveMenuItem(Player player) {
        // 检查快捷栏指定槽位
        ItemStack currentItem = player.getInventory().getItem(MENU_ITEM_SLOT);

        // 如果该槽位已经有菜单物品，不重复给予
        if (isMenuItem(currentItem)) {
            return;
        }

        // 如果该槽位有其他物品，尝试找空槽位
        if (currentItem != null && currentItem.getType() != Material.AIR) {
            // 尝试找一个空槽位
            int emptySlot = player.getInventory().firstEmpty();
            if (emptySlot != -1 && emptySlot < 9) {
                player.getInventory().setItem(emptySlot, createMenuItem());
                player.sendMessage("§a菜单物品已放入快捷栏第" + (emptySlot + 1) + "格");
                return;
            } else {
                // 强制放在第9格（可能会替换现有物品）
                player.getInventory().setItem(MENU_ITEM_SLOT, createMenuItem());
                player.sendMessage("§a菜单物品已放入快捷栏第9格");
                if (currentItem != null) {
                    player.sendMessage("§7原物品已移入背包");
                    player.getInventory().addItem(currentItem);
                }
            }
        } else {
            // 直接放在第9格
            player.getInventory().setItem(MENU_ITEM_SLOT, createMenuItem());
        }
    }

    /**
     * 移除玩家的菜单物品
     */
    public static void removeMenuItem(Player player) {
        // 移除快捷栏中的所有菜单物品
        for (int i = 0; i < 9; i++) {
            ItemStack item = player.getInventory().getItem(i);
            if (isMenuItem(item)) {
                player.getInventory().setItem(i, null);
            }
        }
    }

    /**
     * 启用玩家的菜单物品
     */
    public static void enableMenuItem(Player player) {
        enabledPlayers.add(player.getUniqueId());
        ConfigManager.setMenuItemEnabled(player, true);  // 保存到配置
        giveMenuItem(player);
        player.sendMessage("§a§l[菜单] §7菜单物品已启用");
        player.sendMessage("§7快捷栏中的 §e下界之星 §7可以快速打开菜单");
        player.sendMessage("§7使用 §f/menu toggle §7可以关闭此功能");
    }

    /**
     * 禁用玩家的菜单物品
     */
    public static void disableMenuItem(Player player) {
        enabledPlayers.remove(player.getUniqueId());
        ConfigManager.setMenuItemEnabled(player, false);  // 保存到配置
        removeMenuItem(player);
        player.sendMessage("§c§l[菜单] §7菜单物品已禁用");
        player.sendMessage("§7使用 §f/menu toggle §7可以重新启用");
    }

    /**
     * 切换玩家的菜单物品状态
     */
    public static void toggleMenuItem(Player player) {
        if (isEnabled(player)) {
            disableMenuItem(player);
        } else {
            enableMenuItem(player);
        }
    }

    /**
     * 检查玩家是否启用了菜单物品
     */
    public static boolean isEnabled(Player player) {
        return enabledPlayers.contains(player.getUniqueId());
    }

    /**
     * 玩家加入时自动给予菜单物品（如果已启用）
     */
    public static void onPlayerJoin(Player player) {
        // 从配置文件读取玩家的偏好
        boolean enabled = ConfigManager.isMenuItemEnabled(player);

        if (enabled) {
            enabledPlayers.add(player.getUniqueId());

            // 延迟1秒给予，避免与其他插件冲突
            PlayerMenuPlugin.getInstance().getServer().getScheduler().runTaskLater(
                PlayerMenuPlugin.getInstance(),
                () -> {
                    giveMenuItem(player);
                    // 首次加入时提示
                    if (!ConfigManager.getConfig().contains("players." + player.getUniqueId().toString())) {
                        player.sendMessage("§a§l[菜单系统] §7欢迎使用！");
                        player.sendMessage("§7你的快捷栏中有一个 §e下界之星");
                        player.sendMessage("§7右键点击即可打开菜单");
                        player.sendMessage("§7使用 §f/menu toggle §7可以关闭此功能");
                    }
                },
                20L  // 1秒 = 20 ticks
            );
        }
    }

    /**
     * 检查并补充菜单物品（防止玩家丢弃或删除）
     */
    public static void checkAndReplenish(Player player) {
        if (!isEnabled(player)) {
            return;
        }

        // 检查快捷栏是否有菜单物品
        boolean hasMenuItem = false;
        for (int i = 0; i < 9; i++) {
            if (isMenuItem(player.getInventory().getItem(i))) {
                hasMenuItem = true;
                break;
            }
        }

        // 如果没有，重新给予
        if (!hasMenuItem) {
            giveMenuItem(player);
        }
    }
}
