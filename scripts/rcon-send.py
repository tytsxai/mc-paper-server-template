#!/usr/bin/env python3
"""Minimal RCON sender for Minecraft (Source RCON protocol)."""

import argparse
import socket
import struct
import sys


SERVERDATA_RESPONSE_VALUE = 0
SERVERDATA_EXECCOMMAND = 2
SERVERDATA_AUTH = 3


def _read_packet(sock: socket.socket):
    raw_length = sock.recv(4)
    if len(raw_length) < 4:
        return None

    (length,) = struct.unpack("<i", raw_length)
    data = b""
    while len(data) < length:
        chunk = sock.recv(length - len(data))
        if not chunk:
            break
        data += chunk

    if len(data) != length:
        raise RuntimeError("Incomplete RCON packet")

    req_id, pkt_type = struct.unpack("<ii", data[:8])
    payload = data[8:-2].decode(errors="replace")
    return req_id, pkt_type, payload


def _send_packet(sock: socket.socket, req_id: int, pkt_type: int, payload: str):
    body = struct.pack("<ii", req_id, pkt_type) + payload.encode() + b"\x00\x00"
    sock.sendall(struct.pack("<i", len(body)) + body)


def send_rcon(host: str, port: int, password: str, command: str, timeout: float = 5.0):
    with socket.create_connection((host, port), timeout=timeout) as sock:
        sock.settimeout(timeout)
        _send_packet(sock, 1, SERVERDATA_AUTH, password)
        auth = _read_packet(sock)
        if not auth or auth[0] == -1:
            raise RuntimeError("RCON authentication failed")

        _send_packet(sock, 2, SERVERDATA_EXECCOMMAND, command)

        try:
            while True:
                resp = _read_packet(sock)
                if resp is None:
                    break
                if resp[0] == 2 or resp[1] in (SERVERDATA_RESPONSE_VALUE, SERVERDATA_EXECCOMMAND):
                    break
        except (socket.timeout, ConnectionResetError, BrokenPipeError):
            # The server may drop the connection after a stop command; treat as success.
            pass


def main():
    parser = argparse.ArgumentParser(description="Send a single RCON command to the Minecraft server.")
    parser.add_argument("host")
    parser.add_argument("port", type=int)
    parser.add_argument("password")
    parser.add_argument("command", nargs="+")
    args = parser.parse_args()

    cmd = " ".join(args.command)
    try:
        send_rcon(args.host, args.port, args.password, cmd)
    except Exception as exc:  # noqa: BLE001 - we want a simple CLI
        sys.stderr.write(f"RCON command failed: {exc}\n")
        sys.exit(1)


if __name__ == "__main__":
    main()
