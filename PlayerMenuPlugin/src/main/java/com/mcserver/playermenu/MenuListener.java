package com.mcserver.playermenu;

import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.EventPriority;
import org.bukkit.event.Listener;
import org.bukkit.event.block.Action;
import org.bukkit.event.inventory.InventoryClickEvent;
import org.bukkit.event.player.PlayerDropItemEvent;
import org.bukkit.event.player.PlayerInteractEvent;
import org.bukkit.event.player.PlayerJoinEvent;
import org.bukkit.event.player.PlayerRespawnEvent;
import org.bukkit.inventory.ItemStack;

public class MenuListener implements Listener {

    private boolean isManagedMenuTitle(String title) {
        if (title == null) {
            return false;
        }

        switch (title) {
            case "§6§l玩家菜单":
            case "§6§l传送菜单":
            case "§6§l圈地菜单":
            case "§6§l交易菜单 §7(以物易物)":
            case "§6§l社交菜单":
            case "§6§l工具菜单":
            case "§6§l服务器信息":
            case "§6§l个人设置":
            case "§6§l礼包领取":
                return true;
            default:
                return false;
        }
    }

    @EventHandler
    public void onInventoryClick(InventoryClickEvent event) {
        // 检查是否是我们的菜单
        String title = event.getView().getTitle();
        if (!isManagedMenuTitle(title)) {
            return;
        }

        event.setCancelled(true); // 取消物品移动

        if (event.getCurrentItem() == null || !event.getCurrentItem().hasItemMeta()) {
            return;
        }

        Player player = (Player) event.getWhoClicked();
        ItemStack clickedItem = event.getCurrentItem();

        // 根据菜单标题和物品类型处理点击
        switch (title) {
            case "§6§l玩家菜单":
                handleMainMenuClick(player, clickedItem);
                break;
            case "§6§l传送菜单":
                handleTeleportMenuClick(player, clickedItem);
                break;
            case "§6§l圈地菜单":
                handleClaimMenuClick(player, clickedItem);
                break;
            case "§6§l交易菜单 §7(以物易物)":
                handleEconomyMenuClick(player, clickedItem);
                break;
            case "§6§l社交菜单":
                handleSocialMenuClick(player, clickedItem);
                break;
            case "§6§l工具菜单":
                handleToolMenuClick(player, clickedItem);
                break;
            case "§6§l服务器信息":
                handleInfoMenuClick(player, clickedItem);
                break;
            case "§6§l个人设置":
                handleSettingsMenuClick(player, clickedItem);
                break;
            case "§6§l礼包领取":
                handleKitsMenuClick(player, clickedItem);
                break;
        }
    }

    private void handleMainMenuClick(Player player, ItemStack item) {
        player.closeInventory();

        switch (item.getType()) {
            case ENDER_PEARL:
                MenuManager.openTeleportMenu(player);
                break;
            case GOLDEN_SHOVEL:
                MenuManager.openClaimMenu(player);
                break;
            case GOLD_INGOT:
                MenuManager.openEconomyMenu(player);
                break;
            case PLAYER_HEAD:
                MenuManager.openSocialMenu(player);
                break;
            case DIAMOND_PICKAXE:
                MenuManager.openToolMenu(player);
                break;
            case BOOK:
                MenuManager.openInfoMenu(player);
                break;
            case REDSTONE_TORCH:
                MenuManager.openSettingsMenu(player);
                break;
            case CHEST:
                MenuManager.openKitsMenu(player);
                break;
            case BARRIER:
                // 只是关闭菜单
                break;
        }
    }

    private void handleTeleportMenuClick(Player player, ItemStack item) {
        player.closeInventory();

        switch (item.getType()) {
            case BEACON:
                player.performCommand("spawn");
                break;
            case RED_BED:
                player.performCommand("home");
                break;
            case RECOVERY_COMPASS:
                player.performCommand("back");
                break;
            case COMPASS:
                player.performCommand("warp");
                break;
            case EMERALD:
                player.sendMessage("§a请输入: §f/tpa <玩家名>");
                break;
            case ARROW:
                MenuManager.openMainMenu(player);
                break;
        }
    }

    private void handleClaimMenuClick(Player player, ItemStack item) {
        player.closeInventory();

        switch (item.getType()) {
            case GOLDEN_SHOVEL:
                player.performCommand("kit claim");
                break;
            case EMERALD:
                player.sendMessage("§a请输入: §f/trust <玩家名>");
                break;
            case REDSTONE:
                player.sendMessage("§a请输入: §f/untrust <玩家名>");
                break;
            case BOOK:
                player.performCommand("claimslist");
                break;
            case TNT:
                player.performCommand("claimexplosions");
                break;
            case ARROW:
                MenuManager.openMainMenu(player);
                break;
        }
    }

    private void handleSocialMenuClick(Player player, ItemStack item) {
        player.closeInventory();

        switch (item.getType()) {
            case PAPER:
                player.sendMessage("§a请输入: §f/msg <玩家> <消息>");
                break;
            case WRITABLE_BOOK:
                player.performCommand("list");
                break;
            case NAME_TAG:
                player.sendMessage("§a请输入: §f/nick <昵称>");
                break;
            case CLOCK:
                // 使用 /seen 命令查看玩家信息（包含在线时长）
                player.performCommand("seen " + player.getName());
                break;
            case FEATHER:
                player.performCommand("afk");
                break;
            case ARROW:
                MenuManager.openMainMenu(player);
                break;
        }
    }

    private void handleEconomyMenuClick(Player player, ItemStack item) {
        player.closeInventory();

        switch (item.getType()) {
            case GOLD_NUGGET:  // 查看余额
                player.sendMessage("§c§l[经济系统] §7该功能暂未开通");
                player.sendMessage("§7目前服务器采用 §a以物易物 §7的交易方式");
                player.sendMessage("§7请使用 §e[交易]标志 §7进行物品交换");
                break;

            case EMERALD:  // 出售手持物品
                player.sendMessage("§c§l[经济系统] §7该功能暂未开通");
                player.sendMessage("§7您可以创建 §e[出售]标志 §7来出售物品");
                player.sendMessage("§7其他玩家可用物品交换您的商品");
                break;

            case DIAMOND:  // 出售全部同类
                player.sendMessage("§c§l[经济系统] §7该功能暂未开通");
                player.sendMessage("§7请创建 §e[交易]标志 §7进行物品交易");
                break;

            case GOLD_BLOCK:  // 查看物品价值
                player.sendMessage("§c§l[经济系统] §7该功能暂未开通");
                player.sendMessage("§7物品价值由玩家间交易决定");
                break;

            case PAPER:  // 转账
                player.sendMessage("§c§l[经济系统] §7该功能暂未开通");
                player.sendMessage("§7请使用 §e[交易]标志 §7进行物品交换");
                break;

            case OAK_SIGN:  // 交易标志说明
                player.sendMessage("§6§l╔═══════════════════════════════╗");
                player.sendMessage("§6§l║  交易标志使用指南            ║");
                player.sendMessage("§6§l╚═══════════════════════════════╝");
                player.sendMessage("");
                player.sendMessage("§a§l▸ [交易]标志 §7- 以物易物");
                player.sendMessage("  §f第1行: §e[交易]");
                player.sendMessage("  §f第2行: §e你出售的物品数量 §8(如: 64)");
                player.sendMessage("  §f第3行: §e你要换取的物品:数量 §8(如: 钻石:5)");
                player.sendMessage("  §f第4行: §e留空");
                player.sendMessage("");
                player.sendMessage("§a§l▸ [出售]标志 §7- 出售物品");
                player.sendMessage("  §f第1行: §e[出售]");
                player.sendMessage("  §f第2行: §e物品数量 §8(如: 32)");
                player.sendMessage("  §f第3行: §e价格(物品:数量) §8(如: 铁锭:10)");
                player.sendMessage("  §f第4行: §e留空");
                player.sendMessage("");
                player.sendMessage("§a§l▸ [购买]标志 §7- 收购物品");
                player.sendMessage("  §f第1行: §e[购买]");
                player.sendMessage("  §f第2行: §e收购数量 §8(如: 64)");
                player.sendMessage("  §f第3行: §e支付(物品:数量) §8(如: 金锭:5)");
                player.sendMessage("  §f第4行: §e留空");
                player.sendMessage("");
                player.sendMessage("§e§l示例: 用小麦换钻石");
                player.sendMessage("§8[交易]");
                player.sendMessage("§864 §7(出售64个小麦)");
                player.sendMessage("§8钻石:1 §7(换1个钻石)");
                player.sendMessage("");
                player.sendMessage("§7§o提示: 在标志上放置对应物品箱子");
                player.sendMessage("§7§o玩家右键标志即可进行交易");
                break;

            case ARROW:
                MenuManager.openMainMenu(player);
                break;
        }
    }

    private void handleInfoMenuClick(Player player, ItemStack item) {
        player.closeInventory();

        switch (item.getType()) {
            case COMPASS:
                player.performCommand("getpos");
                break;
            case CLOCK:
                // 使用 /seen 命令查看玩家信息
                player.performCommand("seen " + player.getName());
                break;
            case WRITABLE_BOOK:
                player.performCommand("list");
                break;
            case REDSTONE:
                player.performCommand("ping");
                break;
            case ENDER_EYE:
                player.performCommand("near");
                break;
            case BOOK:
                player.sendMessage("§6§l=== 服务器规则 ===");
                player.sendMessage("§71. 禁止使用作弊、外挂");
                player.sendMessage("§72. 禁止恶意破坏他人建筑");
                player.sendMessage("§73. 友善待人，文明游戏");
                player.sendMessage("§74. 遵守游戏规则，享受游戏");
                break;
            case ARROW:
                MenuManager.openMainMenu(player);
                break;
        }
    }

    private void handleSettingsMenuClick(Player player, ItemStack item) {
        player.closeInventory();

        switch (item.getType()) {
            case ENDER_PEARL:
                player.performCommand("tptoggle");
                break;
            case BARRIER:
                player.sendMessage("§a请输入: §f/ignore <玩家名>");
                break;
            case CHEST:
                player.performCommand("chestsort");
                break;
            case PAPER:
                player.performCommand("mail clear");
                break;
            case WRITABLE_BOOK:
                player.sendMessage("§a请输入: §f/ignorelist");
                break;
            case ARROW:
                MenuManager.openMainMenu(player);
                break;
        }
    }

    private void handleKitsMenuClick(Player player, ItemStack item) {
        player.closeInventory();

        switch (item.getType()) {
            case WOODEN_SWORD:
                player.performCommand("kit starter");
                break;
            case GOLDEN_SHOVEL:
                player.performCommand("kit claim");
                break;
            case CHEST:
                player.performCommand("kit");
                break;
            case DIAMOND:
                player.performCommand("kit daily");
                break;
            case ARROW:
                MenuManager.openMainMenu(player);
                break;
        }
    }

    private void handleToolMenuClick(Player player, ItemStack item) {
        player.closeInventory();

        switch (item.getType()) {
            case CHEST:
                player.performCommand("chestsort");
                break;
            case CRAFTING_TABLE:
                player.performCommand("workbench");
                break;
            case ENDER_CHEST:
                player.performCommand("enderchest");
                break;
            case LEATHER_HELMET:
                player.sendMessage("§a手持物品后输入: §f/hat");
                break;
            case LAVA_BUCKET:
                player.performCommand("disposal");
                break;
            case ARROW:
                MenuManager.openMainMenu(player);
                break;
        }
    }

    /**
     * 玩家加入事件 - 给予菜单物品
     */
    @EventHandler
    public void onPlayerJoin(PlayerJoinEvent event) {
        Player player = event.getPlayer();
        MenuItemManager.onPlayerJoin(player);
    }

    /**
     * 玩家重生事件 - 补充菜单物品
     */
    @EventHandler
    public void onPlayerRespawn(PlayerRespawnEvent event) {
        Player player = event.getPlayer();

        // 延迟2秒给予菜单物品，避免与其他插件冲突
        PlayerMenuPlugin.getInstance().getServer().getScheduler().runTaskLater(
            PlayerMenuPlugin.getInstance(),
            () -> MenuItemManager.checkAndReplenish(player),
            40L  // 2秒 = 40 ticks
        );
    }

    /**
     * 玩家右键点击事件 - 打开菜单
     */
    @EventHandler(priority = EventPriority.HIGH)
    public void onPlayerInteract(PlayerInteractEvent event) {
        // 只处理右键点击
        if (event.getAction() != Action.RIGHT_CLICK_AIR &&
            event.getAction() != Action.RIGHT_CLICK_BLOCK) {
            return;
        }

        Player player = event.getPlayer();
        ItemStack item = event.getItem();

        // 检查是否是菜单物品
        if (MenuItemManager.isMenuItem(item)) {
            event.setCancelled(true);  // 取消默认行为
            MenuManager.openMainMenu(player);
            player.sendMessage("§a§l[菜单] §7已打开菜单界面");
        }
    }

    /**
     * 防止玩家丢弃菜单物品
     */
    @EventHandler
    public void onPlayerDropItem(PlayerDropItemEvent event) {
        ItemStack item = event.getItemDrop().getItemStack();

        if (MenuItemManager.isMenuItem(item)) {
            event.setCancelled(true);  // 取消丢弃
            event.getPlayer().sendMessage("§c§l[菜单] §7菜单物品无法丢弃");
            event.getPlayer().sendMessage("§7如需移除，请使用: §f/menu off");
        }
    }

    /**
     * 防止玩家在菜单GUI中拿走菜单物品
     */
    @EventHandler
    public void onInventoryClickMenuItem(InventoryClickEvent event) {
        ItemStack item = event.getCurrentItem();

        // 如果点击的是菜单物品，且在玩家自己的背包中
        if (MenuItemManager.isMenuItem(item) &&
            event.getClickedInventory() != null &&
            event.getClickedInventory().getHolder() instanceof Player) {

            // 如果是在菜单GUI中点击，取消事件
            String title = event.getView().getTitle();
            if (isManagedMenuTitle(title)) {
                event.setCancelled(true);
            }
        }
    }
}
