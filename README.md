# Minecraft Paper Server Template

一个面向 `Minecraft Java 1.21.8` 的 `Paper` 服务器仓库模板，保留了可复用的脚本、配置和自定义插件源码，同时移除了不适合公开分发的运行时资产与敏感信息。

这个仓库现在定位为：

- 服务器配置模板
- 运维脚本集合
- `PlayerMenuPlugin` 自定义插件源码
- 可公开协作的基础文档

这个仓库现在不包含：

- Paper 服务端二进制
- 第三方插件二进制
- 世界存档
- 玩家数据、数据库、日志
- 本机 `server.properties` 和任何明文口令

## Repository Layout

- `PlayerMenuPlugin/`: 自定义玩家菜单插件源码
- `config/`: Paper 全局与世界默认配置
- `plugins/`: 保留可公开的插件配置与文本资源
- `start.sh` `stop.sh` `stop-graceful.sh`: 启停脚本
- `auto-backup-and-push.sh` `restore-backup.sh`: 备份与恢复脚本
- `send-command.sh` `scripts/rcon-send.py`: RCON 命令发送工具

## Quick Start

### 1. Requirements

- Java 21+
- Linux 或 macOS
- Git
- 可选：`gh`、`screen`、`python3`

### 2. Prepare Runtime Files

你需要自行准备以下运行时文件：

- `paper-1.21.8-60.jar` 或兼容版本
- 所需第三方插件 `.jar`
- 本地 `server.properties`

可以从模板创建本地配置：

```bash
cp server.properties.example server.properties
```

然后至少修改：

- `server-port`
- `rcon.port`
- `rcon.password`
- `management-server-secret`
- 任何与你部署环境相关的地址、密钥和端口

### 3. Run

```bash
./start.sh
./stop-graceful.sh
./stop.sh
```

## Security Notes

这个仓库默认把敏感运行时文件排除在版本控制之外，但你仍然需要自己负责：

- 使用高强度 `rcon.password`
- 不要把真实 `server.properties` 提交回仓库
- 用防火墙限制 RCON 端口
- 不要把数据库、日志、玩家数据和世界存档推到公开仓库

## PlayerMenuPlugin

插件源码位于 `PlayerMenuPlugin/`，使用 Maven 构建：

```bash
mvn -q -f PlayerMenuPlugin/pom.xml test
mvn -q -f PlayerMenuPlugin/pom.xml package
```

插件功能包括：

- 玩家菜单 GUI
- 常用命令快捷入口
- 快捷栏菜单物品
- 基础配置持久化

## Backup and Restore

### Backup

```bash
./auto-backup-and-push.sh
```

### Restore

```bash
./restore-backup.sh <backup-file.tar.gz>
```

说明：

- 恢复前必须先停服
- 恢复脚本会拒绝包含危险路径的压缩包
- 公开仓库中不再跟踪 `backups/`

## Open Source Scope

这个仓库公开的是“服务器工程模板与自定义代码”，不是某台线上服务器的完整运行镜像。

如果你要继续公开维护，建议遵守这条边界：

- 公开：源码、脚本、模板配置、文档
- 私有：密钥、实例配置、世界数据、玩家数据、第三方二进制资产

## License

本仓库中的自定义脚本、文档和 `PlayerMenuPlugin` 源码使用 MIT 许可证。

第三方软件、服务端核心和插件二进制遵循它们各自的许可证，不因为出现在你的部署目录中就自动变成 MIT。
