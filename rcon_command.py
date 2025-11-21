#!/usr/bin/env python3
import socket
import struct
import sys

def send_rcon_command(host, port, password, command):
    """通过RCON发送命令到Minecraft服务器"""
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(10)

    try:
        s.connect((host, port))

        # RCON协议：发送认证请求
        req_id = 1
        auth_data = struct.pack('<ii', req_id, 3) + password.encode('utf-8') + b'\x00\x00'
        s.send(struct.pack('<i', len(auth_data)) + auth_data)

        # 接收认证响应
        resp_size = struct.unpack('<i', s.recv(4))[0]
        resp = s.recv(resp_size)

        # 检查认证是否成功
        resp_id = struct.unpack('<i', resp[:4])[0]
        if resp_id == -1:
            print("认证失败：密码错误")
            return False

        # 发送实际命令
        cmd_data = struct.pack('<ii', req_id + 1, 2) + command.encode('utf-8') + b'\x00\x00'
        s.send(struct.pack('<i', len(cmd_data)) + cmd_data)

        # 接收命令响应
        resp_size = struct.unpack('<i', s.recv(4))[0]
        resp = s.recv(resp_size)

        # 解析响应
        result = resp[8:-2].decode('utf-8', errors='ignore')
        print(f"命令执行结果：\n{result}")
        return True

    except Exception as e:
        print(f"错误：{e}")
        return False
    finally:
        s.close()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("用法: python3 rcon_command.py '<命令>'")
        sys.exit(1)

    command = sys.argv[1]
    send_rcon_command('localhost', 25575, 'admin123', command)
