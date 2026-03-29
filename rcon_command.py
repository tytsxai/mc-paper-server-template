#!/usr/bin/env python3
import argparse
import os
import socket
import struct
import sys


def send_rcon_command(host, port, password, command):
    """通过 RCON 发送命令到 Minecraft 服务器"""
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(10)

    try:
        s.connect((host, port))

        req_id = 1
        auth_data = struct.pack("<ii", req_id, 3) + password.encode("utf-8") + b"\x00\x00"
        s.send(struct.pack("<i", len(auth_data)) + auth_data)

        resp_size = struct.unpack("<i", s.recv(4))[0]
        resp = s.recv(resp_size)
        resp_id = struct.unpack("<i", resp[:4])[0]
        if resp_id == -1:
            print("认证失败：密码错误")
            return False

        cmd_data = struct.pack("<ii", req_id + 1, 2) + command.encode("utf-8") + b"\x00\x00"
        s.send(struct.pack("<i", len(cmd_data)) + cmd_data)

        resp_size = struct.unpack("<i", s.recv(4))[0]
        resp = s.recv(resp_size)
        result = resp[8:-2].decode("utf-8", errors="ignore")
        print(f"命令执行结果：\n{result}")
        return True
    except Exception as e:
        print(f"错误：{e}")
        return False
    finally:
        s.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Send a single RCON command")
    parser.add_argument("command", help="要执行的服务器命令")
    parser.add_argument("--host", default=os.getenv("RCON_HOST", "localhost"))
    parser.add_argument("--port", type=int, default=int(os.getenv("RCON_PORT", "25575")))
    parser.add_argument("--password", default=os.getenv("RCON_PASSWORD"))
    args = parser.parse_args()

    if not args.password:
        print("错误：请通过 --password 或环境变量 RCON_PASSWORD 提供密码")
        sys.exit(1)

    ok = send_rcon_command(args.host, args.port, args.password, args.command)
    sys.exit(0 if ok else 1)
