package com.mcserver.playermenu;

import org.bukkit.plugin.java.JavaPlugin;

public class PlayerMenuPlugin extends JavaPlugin {

    private static PlayerMenuPlugin instance;

    @Override
    public void onEnable() {
        instance = this;

        // 初始化配置管理器
        ConfigManager.init();

        // 注册命令
        getCommand("menu").setExecutor(new MenuCommand());

        // 注册事件监听器
        getServer().getPluginManager().registerEvents(new MenuListener(), this);

        getLogger().info("玩家菜单插件已启用！");
        getLogger().info("菜单物品系统已加载");
        getLogger().info("默认启用状态: " + ConfigManager.isDefaultEnabled());
    }

    @Override
    public void onDisable() {
        // 保存配置
        ConfigManager.saveConfig();

        getLogger().info("玩家菜单插件已禁用！");
    }

    public static PlayerMenuPlugin getInstance() {
        return instance;
    }
}
