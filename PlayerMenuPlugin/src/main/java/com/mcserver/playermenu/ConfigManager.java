package com.mcserver.playermenu;

import org.bukkit.configuration.file.FileConfiguration;
import org.bukkit.configuration.file.YamlConfiguration;
import org.bukkit.entity.Player;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

/**
 * 配置管理器 - 保存玩家的菜单偏好设置
 */
public class ConfigManager {

    private static File configFile;
    private static FileConfiguration config;

    /**
     * 初始化配置
     */
    public static void init() {
        configFile = new File(PlayerMenuPlugin.getInstance().getDataFolder(), "players.yml");

        // 创建数据文件夹
        if (!PlayerMenuPlugin.getInstance().getDataFolder().exists()) {
            PlayerMenuPlugin.getInstance().getDataFolder().mkdirs();
        }

        // 创建配置文件
        if (!configFile.exists()) {
            try {
                configFile.createNewFile();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        config = YamlConfiguration.loadConfiguration(configFile);

        // 设置默认值
        if (!config.contains("default-enabled")) {
            config.set("default-enabled", true);
            saveConfig();
        }
    }

    /**
     * 保存配置
     */
    public static void saveConfig() {
        try {
            config.save(configFile);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * 重载配置
     */
    public static void reloadConfig() {
        config = YamlConfiguration.loadConfiguration(configFile);
    }

    /**
     * 获取玩家的菜单物品启用状态
     */
    public static boolean isMenuItemEnabled(UUID playerUUID) {
        String path = "players." + playerUUID.toString() + ".menu-item-enabled";

        if (config.contains(path)) {
            return config.getBoolean(path);
        }

        // 如果没有设置，返回默认值
        return config.getBoolean("default-enabled", true);
    }

    /**
     * 设置玩家的菜单物品启用状态
     */
    public static void setMenuItemEnabled(UUID playerUUID, boolean enabled) {
        String path = "players." + playerUUID.toString() + ".menu-item-enabled";
        config.set(path, enabled);
        saveConfig();
    }

    /**
     * 获取玩家的菜单物品启用状态（通过Player对象）
     */
    public static boolean isMenuItemEnabled(Player player) {
        return isMenuItemEnabled(player.getUniqueId());
    }

    /**
     * 检查是否已经为玩家保存过菜单偏好
     */
    public static boolean hasPlayerSetting(UUID playerUUID) {
        return config.contains("players." + playerUUID.toString() + ".menu-item-enabled");
    }

    /**
     * 检查是否已经为玩家保存过菜单偏好（通过Player对象）
     */
    public static boolean hasPlayerSetting(Player player) {
        return hasPlayerSetting(player.getUniqueId());
    }

    /**
     * 设置玩家的菜单物品启用状态（通过Player对象）
     */
    public static void setMenuItemEnabled(Player player, boolean enabled) {
        setMenuItemEnabled(player.getUniqueId(), enabled);
    }

    /**
     * 获取默认启用状态
     */
    public static boolean isDefaultEnabled() {
        return config.getBoolean("default-enabled", true);
    }

    /**
     * 设置默认启用状态
     */
    public static void setDefaultEnabled(boolean enabled) {
        config.set("default-enabled", enabled);
        saveConfig();
    }

    /**
     * 获取配置对象
     */
    public static FileConfiguration getConfig() {
        return config;
    }
}
