# Minecraft服务器权限配置摘要

## 权限组结构

### 🔴 admin（管理员组）
**权限等级：** 最高
**显示前缀：** `&c[管理员]`
**显示后缀：** `&e★`

#### 权限列表：
- ✅ `*` - 拥有所有权限

---

### ⚪ member（正常玩家组）
**权限等级：** 中等
**显示前缀：** `&7[玩家]`
**最多家数量：** 3个

#### ✅ 允许的权限：

**基础命令：**
- `minecraft.command.help` - 帮助命令
- `minecraft.command.me` - /me命令
- `minecraft.command.trigger` - 触发器命令
- `minecraft.command.recipe` - 查看配方

**传送系统：**
- `essentials.tpa` - 传送请求
- `essentials.tpahere` - 传送请求（到我这里）
- `essentials.tpaccept` - 接受传送
- `essentials.tpdeny` - 拒绝传送
- `essentials.tptoggle` - 切换传送请求
- `essentials.back` - 返回上一个位置
- `essentials.spawn` - 传送到出生点
- `essentials.warp` - 地标传送
- `essentials.warp.list` - 查看地标列表

**家系统：**
- `essentials.sethome` - 设置家
- `essentials.home` - 回家
- `essentials.delhome` - 删除家
- `essentials.sethome.multiple.member` - 多个家（最多3个）

**经济系统：**
- `essentials.balance` - 查看余额
- `essentials.pay` - 转账
- `essentials.worth` - 查看物品价值
- `essentials.sell` - 出售物品

**交易标志：**
- `essentials.signs.use.*` - 使用所有标志
- `essentials.signs.create.trade` - 创建交易标志
- `essentials.signs.create.buy` - 创建购买标志
- `essentials.signs.create.sell` - 创建出售标志
- `essentials.signs.color` - 标志颜色

**聊天与社交：**
- `essentials.chat.color` - 使用颜色代码
- `essentials.chat.format` - 使用格式代码
- `essentials.msg` - 私聊
- `essentials.msg.color` - 私聊中使用颜色
- `essentials.msg.format` - 私聊中使用格式
- `essentials.nick` - 设置昵称
- `essentials.nick.color` - 昵称颜色
- `essentials.ignore` - 忽略玩家

**邮件系统：**
- `essentials.mail` - 邮件
- `essentials.mail.send` - 发送邮件

**便利功能：**
- `essentials.list` - 查看玩家列表
- `essentials.afk` - 设置AFK
- `essentials.suicide` - 自杀命令
- `essentials.kit` - 使用礼包
- `essentials.compass` - 指南针
- `essentials.depth` - 查看深度
- `essentials.getpos` - 查看坐标
- `essentials.ping` - 查看延迟
- `essentials.near` - 查看附近玩家
- `essentials.time` - 查看时间
- `essentials.book` - 书本命令
- `essentials.workbench` - 便携工作台
- `essentials.enderchest` - 打开末影箱
- `essentials.hat` - 将物品戴在头上
- `essentials.disposal` - 垃圾桶
- `essentials.seen` - 查看玩家信息
- `essentials.whois` - 查看玩家详细信息
- `essentials.realname` - 查看真实名称

**建筑与保护：**
- `essentials.build` - 建造
- `essentials.interact` - 交互
- `essentials.pvp` - PVP
- `griefprevention.createclaims` - 创建领地
- `griefprevention.claims` - 管理领地

#### ❌ 禁止的权限：

**管理员命令：**
- `essentials.give` - 给予物品
- `essentials.item` - 物品命令
- `essentials.unlimited` - 无限物品
- `essentials.gamemode` - 更改游戏模式
- `essentials.fly` - 飞行
- `essentials.god` - 无敌
- `essentials.repair` - 修理物品
- `essentials.kick` - 踢人
- `essentials.ban` - 封禁
- `essentials.tempban` - 临时封禁
- `essentials.mute` - 禁言
- `essentials.tp` - 强制传送
- `essentials.tp.others` - 传送他人
- `essentials.broadcast` - 广播
- `essentials.weather` - 更改天气

**经济管理：**
- `essentials.eco.loan` - 贷款
- `essentials.balance.others` - 查看他人余额

---

### ⚫ guest（游客组）
**权限等级：** 最低
**显示前缀：** `&8[游客]`
**特性：** 只能浏览，不能操作方块

#### ✅ 允许的权限：

**基础浏览：**
- `minecraft.command.help` - 帮助命令
- `essentials.list` - 查看玩家列表
- `essentials.spawn` - 传送到出生点
- `essentials.warp` - 地标传送
- `essentials.warp.list` - 查看地标列表

#### ❌ 禁止的权限：

**世界操作：**
- `essentials.build` - 建造
- `essentials.interact` - 交互
- `essentials.pvp` - PVP
- `griefprevention.createclaims` - 创建领地

**聊天与社交：**
- `essentials.chat.color` - 颜色代码
- `essentials.msg` - 私聊
- `essentials.nick` - 昵称
- `minecraft.command.tell` - 私聊命令

**传送系统：**
- `essentials.sethome` - 设置家
- `essentials.home` - 回家
- `essentials.delhome` - 删除家
- `essentials.tpa` - 传送请求
- `essentials.tpahere` - 传送请求（到我这里）
- `essentials.back` - 返回

**其他功能：**
- `essentials.kit` - 礼包
- `essentials.afk` - AFK
- `essentials.suicide` - 自杀
- `minecraft.command.gamemode.spectator` - 观察者模式

---

## 玩家组分配

- `Xiaofan666hh` → **member**组
- `193158139` → **member**组

---

## TAB插件配置

**排序列表：** admin > member > guest

**显示格式：**
- 管理员：`&c[管理员] &f玩家名 &e★`
- 正常玩家：`&7[玩家] &f玩家名`
- 游客：`&8[游客] &f玩家名`

---

## 权限配置命令总结

所有权限已通过以下方式配置：
1. ✅ 使用 `lp group` 命令创建三个权限组
2. ✅ 使用 `lp group <组名> permission set` 命令设置权限
3. ✅ 使用 `lp group <组名> meta` 命令设置前缀和后缀
4. ✅ 使用 `lp user <玩家名> parent set` 命令分配玩家到组
5. ✅ 所有命令通过RCON远程执行

---

## 配置完成时间
2025-10-05

## 备注
- 所有权限配置已生效并持久化到LuckPerms数据库
- TAB插件已重新加载并应用新配置
- 服务器无需重启，配置立即生效
