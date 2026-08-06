# Minecraft Paper Server Template · MC Paper 服务器工程模板

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE) · [Issues](https://github.com/tytsxai/mc-paper-server-template/issues)

> **关键词**：Minecraft Paper 服务器模板 · Paper 1.21.8 · MC 服运维脚本 · 备份恢复 · RCON · 玩家菜单插件 · Essentials 汉化配置 · LuckPerms 权限模板
>
> **Keywords**: Minecraft Paper server template · Paper 1.21.8 · Minecraft ops scripts · backup restore RCON · PlayerMenu plugin · Essentials Chinese config · Minecraft server scaffolding

## 是什么 / What It Is

面向 **Minecraft Java 1.21.8** 的 **Paper** 服务器**公开工程模板**：保留可复用的启停/备份/RCON 脚本、Paper 与插件配置骨架，以及自定义插件 `PlayerMenuPlugin` 源码；**刻意移除**不适合公开分发的运行时资产与敏感信息。

**English summary**: A clean Paper 1.21.8 server scaffold — scripts, public configs, and a custom player-menu plugin source — without paper.jar, third-party plugin jars, worlds, or secrets.

## 解决什么问题

- 从零搭 Paper 服时缺一套「能直接抄」的脚本与配置结构
- 需要可公开协作的模板：源码与模板配置进 Git，密钥与世界数据留在私有环境
- 需要中文向的玩家菜单、权限摘要、备份与 RCON 运维习惯

## 适合谁

- 自建 Paper / Spigot 系生存服、小团体服的服主与运维
- 想维护自定义 Bukkit/Paper 插件（玩家菜单）的开发者
- 需要把服务器工程「模板化」后再私有部署的团队

## 仓库包含 / 不包含

| 包含 | 不包含 |
|------|--------|
| 启停、优雅停服、备份恢复、RCON 脚本 | Paper 服务端二进制（`paper-*.jar`） |
| `config/` Paper 全局与世界默认配置 | 第三方插件 `.jar` |
| `plugins/` 下可公开的插件配置与文本 | 世界存档、玩家数据、数据库、日志 |
| `PlayerMenuPlugin/` 自定义插件源码 | 本机 `server.properties` 与明文口令 |
| 玩家/菜单/权限相关中文文档 | `backups/` 实际备份包（不跟踪） |

## 核心能力

- **启停**：`start.sh` / `stop-graceful.sh` / `stop.sh`（默认 jar 名 `paper-1.21.8-60.jar`，Java 21+）
- **备份恢复**：`auto-backup-and-push.sh`、`restore-backup.sh`（恢复前须停服；拒绝危险路径）
- **RCON**：`send-command.sh`、`scripts/rcon-send.py`（及根目录 `rcon_command.py`）
- **PlayerMenuPlugin**：玩家菜单 GUI、常用命令快捷入口、快捷栏菜单物品、基础配置持久化
- **插件配置骨架**（配置在仓、二进制需自备）：AuthMe、Essentials、LuckPerms、Vault、ViaVersion/ViaBackwards、CoreProtect、WorldBorder、TAB、spark 等常见生态的公开配置/资源

## 技术栈 / Tech Stack

- Minecraft Java **1.21.8** + **Paper**
- **Java 21+**
- Bash 运维脚本（Linux / macOS）
- 可选：Python 3（RCON）、Maven（构建 `PlayerMenuPlugin`）、`screen`、`gh`

## 快速开始 / Quick Start

### 1. 环境

- Java 21+
- Linux 或 macOS
- Git
- 可选：`python3`、`screen`、`gh`、Maven

### 2. 准备运行时文件（需自备）

```bash
git clone https://github.com/tytsxai/mc-paper-server-template.git
cd mc-paper-server-template

# 1) 放入 Paper 核心（文件名需与 start.sh 默认一致，或设置 JAR_NAME）
#    paper-1.21.8-60.jar

# 2) 本地 server.properties
cp server.properties.example server.properties
# 至少修改：server-port、rcon.port、rcon.password、
# management-server-secret，以及环境相关地址/密钥

# 3) 放入所需第三方插件 .jar 到 plugins/
```

`start.sh` 默认：

- `JAR_NAME=paper-1.21.8-60.jar`
- `JAVA_OPTS=-Xms4G -Xmx10G`（可按机器覆盖环境变量）

### 3. 启动与停止

```bash
./start.sh
./stop-graceful.sh   # 优先优雅停服
./stop.sh            # 强制停服路径
```

## PlayerMenuPlugin

源码：`PlayerMenuPlugin/`（Maven，`artifactId=PlayerMenu`）。

```bash
mvn -q -f PlayerMenuPlugin/pom.xml test
mvn -q -f PlayerMenuPlugin/pom.xml package
# 将 target 产物复制到 plugins/ 后重载或重启服务端
```

功能：玩家菜单 GUI、常用命令快捷入口、快捷栏菜单物品、基础配置持久化。

更多：`MENU_README.txt`、`玩家菜单使用指南.md`。

## 备份与恢复

```bash
./auto-backup-and-push.sh
./restore-backup.sh <backup-file.tar.gz>
```

- 恢复前**必须停服**
- 恢复脚本会拒绝包含危险路径的压缩包
- 公开仓库不跟踪 `backups/` 内容；备份说明见 `备份系统使用说明.md`

## 安全注意事项

- 使用高强度 `rcon.password`（`start.sh` 会对过短/占位密码告警）
- 不要把真实 `server.properties`、密钥、世界与玩家数据提交回公开仓库
- 用防火墙限制 RCON 端口
- 第三方 jar / Paper 核心遵循各自许可证，**不会**因放在部署目录就变成 MIT

## 使用场景

- 新开 Paper 1.21.x 生存服时的工程脚手架
- 团队 fork 后补私有配置与世界，公开层只维护脚本与插件源码
- 教学/文档化「服务器如何启停、备份、RCON、权限与菜单」

## 开源边界

公开的是**服务器工程模板与自定义代码**，不是某台线上服的完整镜像。

- **公开**：源码、脚本、模板配置、文档
- **私有**：密钥、实例配置、世界数据、玩家数据、第三方二进制

## 相关文档（仓内）

| 文档 | 内容 |
|------|------|
| [llms.txt](llms.txt) | AI / 搜索用摘要 |
| `Minecraft服务器玩家完整指南.md` | 玩家向完整说明 |
| `玩家菜单使用指南.md` / `MENU_README.txt` | 菜单 |
| `备份系统使用说明.md` | 备份 |
| `permissions-summary.md` | 权限摘要 |
| `QUICK_START_汉化.txt` / `ESSENTIALS_汉化完成.txt` | 汉化相关说明 |

## 许可证

本仓库自定义脚本、文档与 `PlayerMenuPlugin` 源码：**MIT**（见 [LICENSE](LICENSE)）。

Paper、第三方插件与其它二进制遵循各自许可证。
