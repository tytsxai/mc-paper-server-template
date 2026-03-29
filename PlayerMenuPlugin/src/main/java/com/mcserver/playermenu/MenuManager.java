package com.mcserver.playermenu;

import org.bukkit.Bukkit;
import org.bukkit.Material;
import org.bukkit.entity.Player;
import org.bukkit.inventory.Inventory;
import org.bukkit.inventory.ItemStack;
import org.bukkit.inventory.meta.ItemMeta;

import java.util.Arrays;

public class MenuManager {

    /**
     * 打开主菜单
     */
    public static void openMainMenu(Player player) {
        Inventory menu = Bukkit.createInventory(null, 54, "§6§l玩家菜单");

        // 传送菜单
        ItemStack teleport = createMenuItem(
            Material.ENDER_PEARL,
            "§a§l传送菜单",
            "§7点击打开传送相关功能",
            "§8• 回出生点、回家、回死亡点",
            "§8• 玩家互传、公共地标"
        );
        menu.setItem(10, teleport);

        // 圈地菜单
        ItemStack claim = createMenuItem(
            Material.GOLDEN_SHOVEL,
            "§e§l圈地菜单",
            "§7点击打开圈地保护功能",
            "§8• 获取圈地工具",
            "§8• 管理信任玩家",
            "§8• 查看领地列表"
        );
        menu.setItem(12, claim);

        // 交易菜单（以物易物）
        ItemStack economy = createMenuItem(
            Material.GOLD_INGOT,
            "§6§l交易菜单",
            "§7点击打开交易系统",
            "§a• 交易标志指南（以物易物）",
            "§8• 经济功能暂未开通"
        );
        menu.setItem(14, economy);

        // 社交菜单
        ItemStack social = createMenuItem(
            Material.PLAYER_HEAD,
            "§b§l社交菜单",
            "§7点击打开社交互动功能",
            "§8• 私聊、在线玩家",
            "§8• 设置昵称、游戏时长",
            "§8• AFK挂机"
        );
        menu.setItem(16, social);

        // 工具菜单
        ItemStack tools = createMenuItem(
            Material.DIAMOND_PICKAXE,
            "§d§l工具菜单",
            "§7点击打开实用工具",
            "§8• 箱子整理、便携工作台",
            "§8• 末影箱、垃圾桶",
            "§8• 帽子装饰"
        );
        menu.setItem(28, tools);

        // 信息菜单
        ItemStack info = createMenuItem(
            Material.BOOK,
            "§3§l服务器信息",
            "§7点击查看服务器信息",
            "§8• 服务器规则",
            "§8• 游戏指南",
            "§8• 坐标与TPS"
        );
        menu.setItem(30, info);

        // 设置菜单
        ItemStack settings = createMenuItem(
            Material.REDSTONE_TORCH,
            "§c§l个人设置",
            "§7点击打开个人设置",
            "§8• 传送开关",
            "§8• 聊天设置",
            "§8• 其他功能"
        );
        menu.setItem(32, settings);

        // 礼包菜单
        ItemStack kits = createMenuItem(
            Material.CHEST,
            "§2§l礼包领取",
            "§7点击查看可用礼包",
            "§8• 新手礼包",
            "§8• 每日礼包",
            "§8• 其他礼包"
        );
        menu.setItem(34, kits);

        // 关闭按钮
        ItemStack close = createMenuItem(
            Material.BARRIER,
            "§c§l关闭菜单",
            "§7点击关闭"
        );
        menu.setItem(49, close);

        // 装饰玻璃板
        fillEmptySlots(menu, Material.LIGHT_BLUE_STAINED_GLASS_PANE);

        player.openInventory(menu);
    }

    /**
     * 打开传送菜单
     */
    public static void openTeleportMenu(Player player) {
        Inventory menu = Bukkit.createInventory(null, 27, "§6§l传送菜单");

        // 回出生点
        ItemStack spawn = createMenuItem(
            Material.BEACON,
            "§a§l回出生点",
            "§7点击执行: §f/spawn",
            "§8传送到服务器出生点"
        );
        menu.setItem(10, spawn);

        // 回家
        ItemStack home = createMenuItem(
            Material.RED_BED,
            "§e§l回家",
            "§7点击执行: §f/home",
            "§8传送到你设置的家"
        );
        menu.setItem(11, home);

        // 回死亡点
        ItemStack back = createMenuItem(
            Material.RECOVERY_COMPASS,
            "§c§l回死亡点",
            "§7点击执行: §f/back",
            "§8返回上一个位置/死亡点"
        );
        menu.setItem(12, back);

        // 公共地标
        ItemStack warp = createMenuItem(
            Material.COMPASS,
            "§b§l公共地标",
            "§7点击执行: §f/warp",
            "§8查看可用的公共传送点"
        );
        menu.setItem(13, warp);

        // 玩家互传
        ItemStack tpa = createMenuItem(
            Material.EMERALD,
            "§d§l玩家互传",
            "§7传送到其他玩家",
            "§8输入: §f/tpa <玩家名>",
            "§8或: §f/tpahere <玩家名>"
        );
        menu.setItem(14, tpa);

        // 返回主菜单
        ItemStack back_menu = createMenuItem(
            Material.ARROW,
            "§f§l返回主菜单",
            "§7点击返回"
        );
        menu.setItem(22, back_menu);

        // 装饰
        fillEmptySlots(menu, Material.CYAN_STAINED_GLASS_PANE);

        player.openInventory(menu);
    }

    /**
     * 打开圈地菜单
     */
    public static void openClaimMenu(Player player) {
        Inventory menu = Bukkit.createInventory(null, 27, "§6§l圈地菜单");

        // 获取圈地工具
        ItemStack claimKit = createMenuItem(
            Material.GOLDEN_SHOVEL,
            "§e§l获取圈地工具",
            "§7点击执行: §f/kit claim",
            "§8获得金铲子和说明书"
        );
        menu.setItem(10, claimKit);

        // 信任玩家
        ItemStack trust = createMenuItem(
            Material.EMERALD,
            "§a§l信任玩家",
            "§7允许玩家在你的领地建造",
            "§8输入: §f/trust <玩家名>"
        );
        menu.setItem(11, trust);

        // 移除信任
        ItemStack untrust = createMenuItem(
            Material.REDSTONE,
            "§c§l移除信任",
            "§7移除玩家的领地权限",
            "§8输入: §f/untrust <玩家名>"
        );
        menu.setItem(12, untrust);

        // 查看领地
        ItemStack claimsList = createMenuItem(
            Material.BOOK,
            "§b§l查看领地",
            "§7点击执行: §f/claimslist",
            "§8查看你的所有领地"
        );
        menu.setItem(13, claimsList);

        // 生物破坏开关
        ItemStack explosions = createMenuItem(
            Material.TNT,
            "§6§l生物破坏开关",
            "§7点击执行: §f/claimexplosions",
            "§8开启/关闭领地内生物破坏",
            "§8(苦力怕爆炸、末影人搬方块等)"
        );
        menu.setItem(14, explosions);

        // 返回主菜单
        ItemStack back = createMenuItem(
            Material.ARROW,
            "§f§l返回主菜单",
            "§7点击返回"
        );
        menu.setItem(22, back);

        // 装饰
        fillEmptySlots(menu, Material.YELLOW_STAINED_GLASS_PANE);

        player.openInventory(menu);
    }

    /**
     * 打开社交菜单
     */
    public static void openSocialMenu(Player player) {
        Inventory menu = Bukkit.createInventory(null, 27, "§6§l社交菜单");

        // 私聊
        ItemStack msg = createMenuItem(
            Material.PAPER,
            "§a§l私聊玩家",
            "§7发送私密消息",
            "§8输入: §f/msg <玩家> <消息>",
            "§8快速回复: §f/r <消息>"
        );
        menu.setItem(10, msg);

        // 在线玩家
        ItemStack list = createMenuItem(
            Material.WRITABLE_BOOK,
            "§b§l在线玩家",
            "§7点击执行: §f/list",
            "§8查看当前在线的玩家"
        );
        menu.setItem(11, list);

        // 设置昵称
        ItemStack nick = createMenuItem(
            Material.NAME_TAG,
            "§d§l设置昵称",
            "§7设置个性化昵称",
            "§8输入: §f/nick <昵称>",
            "§8支持颜色代码: §f&a&l绿色粗体"
        );
        menu.setItem(12, nick);

        // 游戏时长
        ItemStack playtime = createMenuItem(
            Material.CLOCK,
            "§e§l玩家信息",
            "§7点击查看你的游戏信息",
            "§8在线时长、首次登录等"
        );
        menu.setItem(13, playtime);

        // AFK挂机
        ItemStack afk = createMenuItem(
            Material.FEATHER,
            "§f§lAFK挂机",
            "§7点击执行: §f/afk",
            "§8设置/取消挂机状态"
        );
        menu.setItem(14, afk);

        // 返回主菜单
        ItemStack back = createMenuItem(
            Material.ARROW,
            "§f§l返回主菜单",
            "§7点击返回"
        );
        menu.setItem(22, back);

        // 装饰
        fillEmptySlots(menu, Material.LIGHT_BLUE_STAINED_GLASS_PANE);

        player.openInventory(menu);
    }

    /**
     * 打开经济菜单
     */
    public static void openEconomyMenu(Player player) {
        Inventory menu = Bukkit.createInventory(null, 27, "§6§l交易菜单 §7(以物易物)");

        // 查看余额 - 标记为暂未开通
        ItemStack balance = createMenuItem(
            Material.GOLD_NUGGET,
            "§e§l查看余额 §c✗",
            "§c功能暂未开通",
            "§7目前服务器暂停货币系统",
            "§7请使用交易标志进行以物易物"
        );
        menu.setItem(10, balance);

        // 出售手持物品 - 标记为暂未开通
        ItemStack sell = createMenuItem(
            Material.EMERALD,
            "§a§l出售物品 §c✗",
            "§c功能暂未开通",
            "§7请创建 §f[出售]标志 §7来出售物品",
            "§8其他玩家可用物品交换"
        );
        menu.setItem(11, sell);

        // 出售全部同类 - 标记为暂未开通
        ItemStack sellAll = createMenuItem(
            Material.DIAMOND,
            "§b§l批量出售 §c✗",
            "§c功能暂未开通",
            "§7请使用交易标志进行交易"
        );
        menu.setItem(12, sellAll);

        // 查看物品价值 - 标记为暂未开通
        ItemStack worth = createMenuItem(
            Material.GOLD_BLOCK,
            "§6§l物品价值 §c✗",
            "§c功能暂未开通",
            "§7物品价值由玩家间交易决定"
        );
        menu.setItem(13, worth);

        // 转账 - 标记为暂未开通
        ItemStack pay = createMenuItem(
            Material.PAPER,
            "§2§l转账 §c✗",
            "§c功能暂未开通",
            "§7请使用交易标志进行物品交换"
        );
        menu.setItem(14, pay);

        // 交易标志说明 - 强调这个可用
        ItemStack signs = createMenuItem(
            Material.OAK_SIGN,
            "§a§l✓ 交易标志指南",
            "§a点击查看详细使用方法",
            "§7§o支持以物易物交易",
            "§e[交易] [出售] [购买] 标志"
        );
        menu.setItem(16, signs);

        // 返回主菜单
        ItemStack back = createMenuItem(
            Material.ARROW,
            "§f§l返回主菜单",
            "§7点击返回"
        );
        menu.setItem(22, back);

        // 装饰 - 使用橙色表示部分功能暂停
        fillEmptySlots(menu, Material.ORANGE_STAINED_GLASS_PANE);

        player.openInventory(menu);
    }

    /**
     * 打开信息菜单
     */
    public static void openInfoMenu(Player player) {
        Inventory menu = Bukkit.createInventory(null, 27, "§6§l服务器信息");

        // 查看坐标
        ItemStack coords = createMenuItem(
            Material.COMPASS,
            "§a§l查看坐标",
            "§7点击执行: §f/getpos",
            "§8显示你的当前坐标"
        );
        menu.setItem(10, coords);

        // 查看游戏时长
        ItemStack playtime = createMenuItem(
            Material.CLOCK,
            "§e§l玩家信息",
            "§7点击查看你的游戏信息",
            "§8在线时长、首次登录等"
        );
        menu.setItem(11, playtime);

        // 查看在线玩家
        ItemStack list = createMenuItem(
            Material.WRITABLE_BOOK,
            "§b§l在线玩家",
            "§7点击执行: §f/list",
            "§8查看当前在线的所有玩家"
        );
        menu.setItem(12, list);

        // 查看延迟
        ItemStack ping = createMenuItem(
            Material.REDSTONE,
            "§c§l查看延迟",
            "§7点击执行: §f/ping",
            "§8查看你的网络延迟"
        );
        menu.setItem(13, ping);

        // 附近玩家
        ItemStack near = createMenuItem(
            Material.ENDER_EYE,
            "§d§l附近玩家",
            "§7点击执行: §f/near",
            "§8查看附近的玩家"
        );
        menu.setItem(14, near);

        // 服务器规则
        ItemStack rules = createMenuItem(
            Material.BOOK,
            "§6§l服务器规则",
            "§7点击查看",
            "§8§o输入: §f/rules",
            "§8§o(如果有规则命令)"
        );
        menu.setItem(16, rules);

        // 返回主菜单
        ItemStack back = createMenuItem(
            Material.ARROW,
            "§f§l返回主菜单",
            "§7点击返回"
        );
        menu.setItem(22, back);

        // 装饰
        fillEmptySlots(menu, Material.CYAN_STAINED_GLASS_PANE);

        player.openInventory(menu);
    }

    /**
     * 打开设置菜单
     */
    public static void openSettingsMenu(Player player) {
        Inventory menu = Bukkit.createInventory(null, 27, "§6§l个人设置");

        // 传送请求开关
        ItemStack tpToggle = createMenuItem(
            Material.ENDER_PEARL,
            "§a§l传送请求开关",
            "§7点击执行: §f/tptoggle",
            "§8开启/关闭接收传送请求"
        );
        menu.setItem(10, tpToggle);

        // 忽略玩家
        ItemStack ignore = createMenuItem(
            Material.BARRIER,
            "§c§l忽略玩家",
            "§7屏蔽某个玩家的消息",
            "§8输入: §f/ignore <玩家名>"
        );
        menu.setItem(11, ignore);

        // 箱子整理开关
        ItemStack chestSort = createMenuItem(
            Material.CHEST,
            "§e§l箱子整理开关",
            "§7点击执行: §f/chestsort",
            "§8开启/关闭自动箱子整理"
        );
        menu.setItem(12, chestSort);

        // 清空邮件
        ItemStack clearMail = createMenuItem(
            Material.PAPER,
            "§b§l清空邮件",
            "§7点击执行: §f/mail clear",
            "§8清空所有已读邮件"
        );
        menu.setItem(13, clearMail);

        // 查看已忽略玩家
        ItemStack ignoredList = createMenuItem(
            Material.WRITABLE_BOOK,
            "§7§l已忽略列表",
            "§7查看已忽略的玩家",
            "§8输入: §f/ignorelist"
        );
        menu.setItem(14, ignoredList);

        // 返回主菜单
        ItemStack back = createMenuItem(
            Material.ARROW,
            "§f§l返回主菜单",
            "§7点击返回"
        );
        menu.setItem(22, back);

        // 装饰
        fillEmptySlots(menu, Material.RED_STAINED_GLASS_PANE);

        player.openInventory(menu);
    }

    /**
     * 打开礼包菜单
     */
    public static void openKitsMenu(Player player) {
        Inventory menu = Bukkit.createInventory(null, 27, "§6§l礼包领取");

        // 新手礼包
        ItemStack starter = createMenuItem(
            Material.WOODEN_SWORD,
            "§a§l新手礼包",
            "§7点击执行: §f/kit starter",
            "§8领取新手礼包",
            "§8包含基础工具和食物"
        );
        menu.setItem(10, starter);

        // 圈地礼包
        ItemStack claim = createMenuItem(
            Material.GOLDEN_SHOVEL,
            "§e§l圈地礼包",
            "§7点击执行: §f/kit claim",
            "§8领取圈地工具包",
            "§8包含金铲子和说明书"
        );
        menu.setItem(11, claim);

        // 查看所有礼包
        ItemStack kits = createMenuItem(
            Material.CHEST,
            "§b§l查看所有礼包",
            "§7点击执行: §f/kit",
            "§8查看所有可用礼包"
        );
        menu.setItem(13, kits);

        // 每日礼包（如果有）
        ItemStack daily = createMenuItem(
            Material.DIAMOND,
            "§d§l每日礼包",
            "§7点击执行: §f/kit daily",
            "§8领取每日奖励",
            "§8§o(如果服务器有配置)"
        );
        menu.setItem(15, daily);

        // 返回主菜单
        ItemStack back = createMenuItem(
            Material.ARROW,
            "§f§l返回主菜单",
            "§7点击返回"
        );
        menu.setItem(22, back);

        // 装饰
        fillEmptySlots(menu, Material.GREEN_STAINED_GLASS_PANE);

        player.openInventory(menu);
    }

    /**
     * 打开工具菜单
     */
    public static void openToolMenu(Player player) {
        Inventory menu = Bukkit.createInventory(null, 27, "§6§l工具菜单");

        // 箱子整理
        ItemStack chestSort = createMenuItem(
            Material.CHEST,
            "§e§l箱子整理",
            "§7点击执行: §f/chestsort",
            "§8开启/关闭自动箱子整理",
            "§8关闭箱子时自动整理物品"
        );
        menu.setItem(10, chestSort);

        // 便携工作台
        ItemStack workbench = createMenuItem(
            Material.CRAFTING_TABLE,
            "§a§l便携工作台",
            "§7点击执行: §f/workbench",
            "§8随时随地打开工作台"
        );
        menu.setItem(11, workbench);

        // 末影箱
        ItemStack enderchest = createMenuItem(
            Material.ENDER_CHEST,
            "§d§l末影箱",
            "§7点击执行: §f/enderchest",
            "§8随时访问个人末影箱"
        );
        menu.setItem(12, enderchest);

        // 帽子装饰
        ItemStack hat = createMenuItem(
            Material.LEATHER_HELMET,
            "§b§l帽子装饰",
            "§7将物品戴在头上",
            "§8手持物品后输入: §f/hat",
            "§8移除: §f/hat remove"
        );
        menu.setItem(13, hat);

        // 垃圾桶
        ItemStack disposal = createMenuItem(
            Material.LAVA_BUCKET,
            "§c§l虚拟垃圾桶",
            "§7点击执行: §f/disposal",
            "§8打开虚拟垃圾桶",
            "§c§l警告: 放入的物品会永久删除！"
        );
        menu.setItem(14, disposal);

        // 返回主菜单
        ItemStack back = createMenuItem(
            Material.ARROW,
            "§f§l返回主菜单",
            "§7点击返回"
        );
        menu.setItem(22, back);

        // 装饰
        fillEmptySlots(menu, Material.PURPLE_STAINED_GLASS_PANE);

        player.openInventory(menu);
    }

    /**
     * 创建菜单物品
     */
    private static ItemStack createMenuItem(Material material, String name, String... lore) {
        ItemStack item = new ItemStack(material);
        ItemMeta meta = item.getItemMeta();

        meta.setDisplayName(name);
        if (lore.length > 0) {
            meta.setLore(Arrays.asList(lore));
        }

        item.setItemMeta(meta);
        return item;
    }

    /**
     * 填充空槽位
     */
    private static void fillEmptySlots(Inventory inventory, Material glassMaterial) {
        ItemStack glass = new ItemStack(glassMaterial);
        ItemMeta glassMeta = glass.getItemMeta();
        glassMeta.setDisplayName(" ");
        glass.setItemMeta(glassMeta);

        for (int i = 0; i < inventory.getSize(); i++) {
            if (inventory.getItem(i) == null) {
                inventory.setItem(i, glass);
            }
        }
    }
}
