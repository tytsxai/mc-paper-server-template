# 🎮 Minecraft Java 服务器

一个功能完整的 Minecraft 1.21.8 Paper 服务器，配置了多种实用插件和完善的玩家欢迎系统。

## 📋 服务器信息

- **版本**: Minecraft 1.21.8 (Paper)
- **服务器核心**: Paper 1.21.8-60
- **RCON**: 已启用（端口 20502，建议自定义强密码）
- **QQ 群**: 539136479

## ✨ 主要功能

### 🔐 安全系统
- **正版登录** - 使用官方账号登录，无需额外注册插件

### 🛡️ 保护系统
- **GriefPrevention** - 领地保护系统，防止恶意破坏
- **CoreProtect** - 方块记录与回滚系统

### 🎁 玩家系统
- **完善的欢迎系统** - 玩家加入时自动显示欢迎消息
- **新手礼包系统** - 两种礼包（新手、工具）
- **传送系统** - 设置家、回家、传送等功能

### 🌍 世界管理
- **FastAsyncWorldEdit** - 强大的世界编辑/刷地工具

### 💰 经济系统
- **Vault** - 经济系统核心
- **EssentialsX** - 完整的服务器管理工具

## 📦 已安装插件列表

| 插件名称 | 版本 | 功能说明 |
|---------|------|---------|
| EssentialsX | 2.21.2 | 服务器管理核心、基础命令 |
| EssentialsXChat | 2.21.2 | 聊天管理 |
| EssentialsXSpawn | 2.21.2 | 出生点管理 |
| GriefPrevention | 16.18.4 | 领地保护 |
| CoreProtect | 23.0 | 方块记录与回滚 |
| LuckPerms | 5.5.15 | 权限管理 |
| FastAsyncWorldEdit | 2.13.3 | 世界编辑/刷地 |
| ChestSort | 14.2.0 | 箱子自动整理 |
| GSit | 2.4.3 | 坐下/躺下/动作 |
| PlayerMenu | 1.0 | 玩家功能菜单 |
| TAB | 5.0.7 | Tab 列表与头衔显示 |
| ViaVersion | 5.5.0 | 支持高版本客户端进服 |
| ViaBackwards | 5.5.0 | 支持低版本客户端进服 |
| Vault | - | 经济/权限桥接 |
| WorldBorder | - | 世界边界支持（当前未启用限制） |
| ProtocolLib | - | 协议支持库 |

## 🎁 礼包系统

### 新手礼包 (`/kit welcome`)
- **冷却时间**: 一次性
- **内容**: 
  - 木制基础工具（木剑、木镐、木斧、木铲）
  - 食物：面包 16 个、牛排 8 个
  - 火把 32 个

### 工具礼包 (`/kit tools`)
- **冷却时间**: 10 秒
- **内容**:
  - 木剑、木镐、木斧、木铲（补充基础工具）

## 🚀 快速开始

### 1. 环境要求
- Java 21 或更高版本
- Linux 系统（推荐）
- 默认内存参数为 -Xms4G / -Xmx10G，可按机器配置设置 `JAVA_OPTS`

### 2. 启动服务器

```bash
# 启动服务器
./start.sh

# 平滑停止（优先）
./stop-graceful.sh

# 强制停止
./stop.sh

# 重新启动服务器（应用配置更改）
# 可手动先 ./stop-graceful.sh 再 ./start.sh
```

### 3. 首次配置

1. 确保已接受 EULA（`eula.txt` 中设置 `eula=true`）
2. 修改 `server.properties` 中的服务器设置
3. 配置插件设置（在 `plugins/` 目录下）
4. 启动服务器

## 📝 常用命令

### 玩家命令
```
/motd - 查看欢迎消息
/rules - 查看服务器规则
/kit welcome - 领取新手礼包（一次性）
/kit tools - 工具礼包（冷却 10 秒）
/spawn - 回到出生点
/sethome [名称] - 设置家
/home [名称] - 回家
/tpa <玩家名> - 请求传送到玩家
/tpaccept - 接受传送请求
```

### 管理员命令
```
/op <玩家名> - 给予玩家管理员权限
/deop <玩家名> - 移除玩家管理员权限
/setspawn - 设置出生点
/setspawn newbies - 设置新手出生点
/co inspect - 启用方块检查模式
/co rollback - 回滚操作
```

## 🎨 玩家欢迎系统

### 主动提示功能

1. **玩家加入时立即显示欢迎消息**
   - 无延迟自动显示
   - 包含服务器信息、插件功能、命令列表
   - 显示 QQ 群号和社区信息

2. **新玩家首次加入全服广播**
   - 全服玩家看到欢迎新人的消息
   - 提示新玩家领取新手礼包
   - 显示 QQ 群号

3. **玩家加入/离开消息**
   - 显示玩家加入服务器的消息
   - 显示当前在线人数
   - 显示玩家离开服务器的消息

### 配置文件位置

- **欢迎消息**: `plugins/Essentials/motd.txt`
- **服务器规则**: `plugins/Essentials/rules.txt`
- **礼包配置**: `plugins/Essentials/kits.yml`
- **主配置**: `plugins/Essentials/config.yml`

## 🔧 配置说明

### 服务器配置
- `server.properties` - 服务器基本配置
- `bukkit.yml` - Bukkit 配置
- `spigot.yml` - Spigot 配置
- `config/paper-global.yml` - Paper 全局配置

### 插件配置
所有插件配置文件位于 `plugins/<插件名>/` 目录下。

### 重要配置项

#### Essentials 配置 (`plugins/Essentials/config.yml`)
```yaml
# 玩家加入时立即显示欢迎消息（无延迟）
delay-motd: 0

# 自定义加入消息
custom-join-message: "&e&l[+] &a{PLAYER} &7加入了服务器 &8[&b在线: {ONLINE}&8]"

# 自定义离开消息
custom-quit-message: "&c&l[-] &7{PLAYER} &7离开了服务器"

# 新玩家首次加入广播
newbies:
  announce-format: '&6&l✦✦✦ &d欢迎新玩家 &b{DISPLAYNAME} &d首次加入服务器！&6&l✦✦✦\n&a&l快使用 &f/kit welcome &a&l领取新手礼包！ &7| &3QQ群: &f539136479'
  spawnpoint: newbies
```

## 📊 服务器管理

### 备份
建议定期备份以下内容：
- 世界数据 (`world/`, `world_nether/`, `world_the_end/`)
- 插件配置 (`plugins/*/config.yml`)
- 玩家数据 (`plugins/*/playerdata/`)

### 性能优化
- 已配置 Paper 服务器核心，性能优于 Spigot
- 可在 `config/paper-global.yml` 中调整性能参数
- 建议定期清理日志文件

### 安全建议
- 定期更新服务器核心和插件
- 使用白名单模式（如需要）
- 配置防火墙规则
- 定期检查 CoreProtect 日志

## 🐛 故障排除

### 服务器无法启动
1. 检查 Java 版本是否为 21+
2. 检查 `eula.txt` 是否设置为 `true`
3. 查看 `logs/latest.log` 获取错误信息

### 插件无法加载
1. 检查插件版本是否与服务器版本兼容
2. 查看 `logs/latest.log` 中的插件加载信息
3. 确保插件依赖已安装（如 Vault、ProtocolLib）

### 玩家无法加入
1. 检查服务器端口是否开放（当前为 20501）
2. 检查白名单设置
3. 确认玩家使用正版账号登录

## 📞 联系方式

- **QQ 群**: 539136479
- **GitHub**: https://github.com/tytsxai/mc-java-fuwuqi

## 📄 许可证

本项目仅供学习和个人使用。所有插件遵循其各自的许可证。

## 🙏 致谢

感谢以下开源项目：
- [Paper](https://papermc.io/) - 高性能 Minecraft 服务器
- [EssentialsX](https://essentialsx.net/) - 服务器管理工具
- [GriefPrevention](https://github.com/TechFortress/GriefPrevention) - 领地保护
- [CoreProtect](https://coreprotect.net/) - 方块记录
- [LuckPerms](https://luckperms.net/) - 权限管理
- 以及所有其他优秀的插件开发者

## 📝 更新日志

### 2025-10-04
- ✅ 初始化服务器项目
- ✅ 安装并配置所有核心插件
- ✅ 配置完整的玩家欢迎系统
- ✅ 创建基础礼包（新手、工具）
- ✅ 配置新玩家首次加入广播
- ✅ 设置所有主动提示功能
- ✅ 上传到 GitHub 仓库
