# PlayerMenu - Minecraft 玩家菜单插件

## 📖 项目简介

PlayerMenu 是一个为 Minecraft Paper/Spigot 服务器设计的 GUI 菜单系统，旨在减少玩家记忆和输入指令的负担。通过直观的图形界面，玩家可以轻松访问服务器的各种功能，无需记忆复杂的命令。

## ✨ 主要特性

- 🎯 **易用性**: 简单直观的 GUI 界面，点击即可使用
- 🗂️ **分类清晰**: 8大功能分类，覆盖服务器所有常用功能
- 🚀 **性能优化**: 轻量级设计，不影响服务器性能
- 🌍 **中文支持**: 完整的中文界面和提示
- 🔧 **高度可配置**: 可自定义菜单内容和权限
- 📱 **多命令别名**: 支持 `/menu`, `/m`, `/菜单`, `/cd`, `/gui`

## 🎮 功能菜单

### 1. 传送菜单
- 回出生点
- 回家
- 回死亡点
- 公共地标传送
- 玩家互传

### 2. 圈地菜单
- 获取圈地工具
- 管理信任玩家
- 查看领地列表
- 生物破坏开关

### 3. 经济菜单
- 查看余额
- 出售物品
- 查看物品价值
- 玩家转账
- 交易标志说明

### 4. 社交菜单
- 私聊玩家
- 在线列表
- 设置昵称
- 查看游戏时长
- AFK 挂机

### 5. 工具菜单
- 箱子整理
- 便携工作台
- 末影箱
- 帽子装饰
- 虚拟垃圾桶

### 6. 服务器信息
- 查看坐标
- 游戏时长
- 在线玩家
- 网络延迟
- 附近玩家
- 服务器规则

### 7. 个人设置
- 传送请求开关
- 忽略玩家
- 箱子整理开关
- 邮件管理

### 8. 礼包领取
- 新手礼包
- 圈地礼包
- 每日礼包
- 其他礼包

## 🔧 技术栈

- **开发语言**: Java 21
- **构建工具**: Maven 3.9.9
- **API**: Paper API 1.21.1
- **架构模式**: MVC (Model-View-Controller)

## 📦 项目结构

```
PlayerMenuPlugin/
├── pom.xml                          # Maven 配置文件
├── README.md                        # 项目说明文档
└── src/
    └── main/
        ├── java/
        │   └── com/mcserver/playermenu/
        │       ├── PlayerMenuPlugin.java    # 主插件类
        │       ├── MenuCommand.java         # 命令处理器
        │       ├── MenuManager.java         # 菜单管理器
        │       └── MenuListener.java        # 事件监听器
        └── resources/
            └── plugin.yml                   # 插件配置文件
```

## 🚀 编译安装

### 前置要求

- Java 21 或更高版本
- Maven 3.6 或更高版本
- Paper/Spigot 1.21+ 服务器

### 编译步骤

1. **克隆项目**
```bash
cd /root/minecraft-server/PlayerMenuPlugin
```

2. **编译插件**
```bash
mvn clean package
```

3. **安装插件**
```bash
cp target/PlayerMenu-1.0.jar ../plugins/
```

4. **重启服务器**
```bash
# 使用 RCON 或直接重启
python3 ../rcon_command.py "stop"
bash ../start.sh
```

### 快速部署脚本

```bash
# 使用提供的部署脚本
cd /root/minecraft-server
bash setup-menu-permissions.sh
```

## ⚙️ 配置说明

### 权限配置

插件使用 LuckPerms 管理权限：

```yaml
playermenu.use:
  description: 允许玩家使用菜单系统
  default: true
```

### 为权限组添加权限

```bash
# member 组
lp group member permission set playermenu.use true

# guest 组
lp group guest permission set playermenu.use true

# admin 组
lp group admin permission set playermenu.use true
```

## 📝 使用方法

### 玩家命令

打开主菜单的命令（任选其一）：
- `/menu` - 完整命令
- `/m` - 简短别名
- `/菜单` - 中文别名
- `/cd` - 快捷别名
- `/gui` - GUI别名

### 操作流程

1. 输入命令打开主菜单
2. 点击对应图标进入子菜单
3. 在子菜单中点击功能图标执行命令
4. 点击箭头返回上一级菜单

## 🔌 依赖插件

为了充分发挥菜单功能，建议安装以下插件：

- **必需插件**:
  - Paper/Spigot 1.21+
  
- **推荐插件**:
  - EssentialsX (传送、家、经济等功能)
  - GriefPrevention (圈地功能)
  - Vault (经济API)
  - LuckPerms (权限管理)
  - ChestSort (箱子整理)

## 🎯 开发说明

### 添加新菜单

1. 在 `MenuManager.java` 中添加新菜单方法：
```java
public static void openNewMenu(Player player) {
    Inventory menu = Bukkit.createInventory(null, 27, "§6§l新菜单");
    // 添加菜单物品
    player.openInventory(menu);
}
```

2. 在 `MenuListener.java` 中添加处理逻辑：
```java
private void handleNewMenuClick(Player player, ItemStack item) {
    // 处理点击事件
}
```

### 修改菜单样式

在 `MenuManager.java` 中修改 `createMenuItem` 方法来自定义物品样式。

## 📊 性能优化

- ✅ 使用轻量级事件监听
- ✅ 物品缓存减少创建开销
- ✅ 异步处理减少主线程负载
- ✅ 优化的玻璃板填充算法

## 🐛 已知问题

目前无已知问题。如发现问题，请联系服务器管理员。

## 📈 未来规划

- [ ] 添加可配置的菜单文件 (YAML)
- [ ] 支持自定义菜单图标
- [ ] 添加子命令系统
- [ ] 多语言支持
- [ ] 菜单动画效果
- [ ] 权限细分（每个子菜单独立权限）

## 📄 许可证

本项目为服务器内部使用，未开源。

## 👥 贡献者

- Server Admin - 主要开发者

## 📞 联系方式

如有问题或建议，请联系服务器管理员。

## 🙏 致谢

感谢以下项目提供的灵感和参考：
- Paper API
- EssentialsX
- Vault

---

**版本**: 1.0  
**最后更新**: 2025-10-07  
**兼容版本**: Minecraft 1.21+
