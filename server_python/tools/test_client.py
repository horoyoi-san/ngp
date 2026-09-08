"""
Automated Test Client
Simulates client connection to both HTTP Gateway and TCP UX RPC server.
"""

import sys
import os
import time
import socket
import struct
import urllib.request
import json

SERVER_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if SERVER_DIR not in sys.path:
    sys.path.insert(0, SERVER_DIR)

from network.protocol import (
    BinaryWriter,
    BinaryReader,
    RpcPacket,
    MODE_INVOKE,
    MODE_RETURN,
    MODE_NOTIFY,
)


def test_http_gateway():
    print("\n--- 1. Testing HTTP Gateway ---")
    url = "http://127.0.0.1:8080/server_list"
    try:
        req = urllib.request.urlopen(url, timeout=5)
        body = req.read().decode("utf-8")
        data = json.loads(body)
        print(f"[HTTP OK] Server list received:")
        for s in data.get("servers", []):
            print(f"  - {s.get('name')} -> {s.get('ip')}:{s.get('port')}")
        assert data.get("code") == 200
        return True
    except Exception as e:
        print(f"[HTTP FAIL] {e}")
        return False


def test_tcp_handshake():
    print("\n--- 2. Testing TCP UX RPC Handshake ---")
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(5.0)

    try:
        s.connect(("127.0.0.1", 8888))
        print("[TCP] Connected to 127.0.0.1:8888")

        # Step 1: Send CheckVersion (34700853)
        w = BinaryWriter()
        w.write_string("dummy_code_md5")
        w.write_int32(100)  # client version
        pkt = RpcPacket(
            mode=MODE_INVOKE,
            method_id=34700853,
            invoke_id=1,
            payload=w.get_bytes(),
        )
        s.sendall(pkt.encode(include_framing=True))
        print("[TCP Sent] CheckVersion (34700853) invokeId=1")

        # Read response
        resp = read_packet(s)
        print(f"[TCP Recv] Mode={resp.mode}, MethodId={resp.method_id}, InvokeId={resp.invoke_id}, ErrId={resp.err_id}")
        assert resp.mode == MODE_RETURN
        assert resp.method_id == 34700853
        assert resp.err_id == 0
        print("  -> CheckVersion SUCCESS!")

        # Step 2: Send TryLogin (34529582)
        w = BinaryWriter()
        w.write_int32(10001)  # aid
        w.write_string("dummy_token")
        pkt2 = RpcPacket(
            mode=MODE_INVOKE,
            method_id=34529582,
            invoke_id=2,
            payload=w.get_bytes(),
        )
        s.sendall(pkt2.encode(include_framing=True))
        print("[TCP Sent] TryLogin (34529582) invokeId=2")

        # Read responses (Expected: Return TryLogin + Notify SyncRoleList)
        resp2 = read_packet(s)
        print(f"[TCP Recv] Mode={resp2.mode}, MethodId={resp2.method_id}, ErrId={resp2.err_id}")
        assert resp2.mode == MODE_RETURN
        assert resp2.err_id == 0
        print("  -> TryLogin SUCCESS!")

        resp3 = read_packet(s)
        print(f"[TCP Recv] Mode={resp3.mode}, MethodId={resp3.method_id} (Expected SyncRoleList=35167428)")
        assert resp3.method_id == 35167428
        r = BinaryReader(resp3.payload)
        pid = r.read_uint64()
        print(f"  -> SyncRoleList SUCCESS! Assigned PID = {pid}")

        # Step 3: Send RequestEnterGame (34566515)
        pkt3 = RpcPacket(
            mode=MODE_INVOKE,
            method_id=34566515,
            invoke_id=3,
            payload=b"",
        )
        s.sendall(pkt3.encode(include_framing=True))
        print("[TCP Sent] RequestEnterGame (34566515) invokeId=3")

        resp4 = read_packet(s)
        print(f"[TCP Recv] Mode={resp4.mode}, MethodId={resp4.method_id}, ErrId={resp4.err_id}")
        assert resp4.mode == MODE_RETURN
        assert resp4.err_id == 0

        # Read Gate info from Reader[580]
        r = BinaryReader(resp4.payload)
        aid = r.read_int32()
        assigned_pid = r.read_uint64()
        mark = r.read_byte()
        gate_aid = r.read_int32()
        gate_pid = r.read_uint64()
        gate_ip = r.read_string()
        gate_port = r.read_int32()
        token = r.read_string()
        print(f"  -> RequestEnterGame SUCCESS! Gate Target: {gate_ip}:{gate_port}, Token: {token}")

        s.close()
        return True
    except Exception as e:
        print(f"[TCP FAIL] {e}")
        import traceback

        traceback.print_exc()
        s.close()
        return False


def read_packet(sock: socket.socket) -> RpcPacket:
    # Read 4-byte length prefix
    len_data = sock.recv(4)
    if len(len_data) < 4:
        raise EOFError("Socket closed while reading length prefix")
    length = struct.unpack("<I", len_data)[0]

    # Read packet body
    body = bytearray()
    while len(body) < length:
        chunk = sock.recv(min(4096, length - len(body)))
        if not chunk:
            raise EOFError("Socket closed while reading packet body")
        body.extend(chunk)

    return RpcPacket.decode(bytes(body))


if __name__ == "__main__":
    http_ok = test_http_gateway()
    tcp_ok = test_tcp_handshake()
    if http_ok and tcp_ok:
        print("\n==========================================")
        print("  ALL TESTS PASSED! SERVER IS FUNCTIONAL! ")
        print("==========================================")
    else:
        print("\nSome tests failed. Check output above.")
