# 启用 RCON 远程管理

## 什么是 RCON？
RCON 是 Minecraft 服务器的远程控制协议，允许你在不登录游戏的情况下执行服务器命令。

## 如何启用 RCON

### 1. 修改 server.properties
```bash
cd /root/minecraft-server
nano server.properties
```

找到并修改以下行：
```properties
enable-rcon=true
rcon.port=25575
rcon.password=你的密码（请设置一个强密码）
```

### 2. 重启服务器
```bash
cd /root/minecraft-server
pkill -f paper-1.21.8-60.jar
bash start.sh
```

### 3. 使用 RCON 发送命令
安装 mcrcon：
```bash
apt-get install mcrcon -y
```

发送命令：
```bash
mcrcon -H localhost -P 25575 -p 你的密码 "essentials reload"
```

## 注意事项
- RCON 密码要设置强密码
- 如果服务器有防火墙，确保 25575 端口只允许本地访问
- 不要将 RCON 密码泄露给他人
