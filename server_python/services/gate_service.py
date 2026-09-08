"""
Gate Service Handlers
Handles ClientToGateDelegate RPCs: Gate.Login, GetServerTime, Network Quality
"""

import time
from typing import Dict, Any, List
from network.protocol import (
    BinaryWriter,
    BinaryReader,
    RpcPacket,
    MODE_RETURN,
    MODE_NOTIFY,
)
from database.player_storage import PlayerStorage

METHOD_GATE_LOGIN = 52023760
METHOD_GET_SERVER_TIME = 52951195
METHOD_REPORT_NETWORK_QUALITY = 52443839
METHOD_CLOSE_CONNECTION = 52140059


class GateService:
    def __init__(self, storage: PlayerStorage, config: Dict[str, Any]):
        self.storage = storage
        self.config = config

    def handle_gate_login(self, packet: RpcPacket, session) -> List[RpcPacket]:
        """Client authenticates to Gate server."""
        reader = BinaryReader(packet.payload)
        pid = reader.read_uint64() if reader.remaining >= 8 else 1000000001
        token = reader.read_string() if reader.remaining > 0 else ""
        print(f"[GateService] Gate.Login: pid={pid}, token={token}")

        player = self.storage.get_player_by_pid(pid)
        if player:
            session.player = player
            session.account_name = player.get("account")

        # Return errId = 0 (OK)
        resp = RpcPacket(
            mode=MODE_RETURN,
            method_id=METHOD_GATE_LOGIN,
            invoke_id=packet.invoke_id,
            err_id=0,
            payload=b"",
        )
        return [resp]

    def handle_get_server_time(self, packet: RpcPacket, session) -> List[RpcPacket]:
        """Client requesting or syncing server time."""
        reader = BinaryReader(packet.payload)
        client_time = reader.read_double() if reader.remaining >= 8 else time.time()

        now = time.time()
        print(f"[GateService] GetServerTime: client={client_time}, server={now}")

        w = BinaryWriter()
        w.write_double(now)
        resp = RpcPacket(
            mode=MODE_RETURN,
            method_id=METHOD_GET_SERVER_TIME,
            invoke_id=packet.invoke_id,
            err_id=0,
            payload=w.get_bytes(),
        )
        return [resp]

    def handle_report_network_quality(self, packet: RpcPacket, session) -> List[RpcPacket]:
        """Client telemetry (ping/jitter), fire and forget."""
        return []

    def handle_close_connection(self, packet: RpcPacket, session) -> List[RpcPacket]:
        """Client closing gate connection."""
        print("[GateService] Client requested close connection")
        resp = RpcPacket(
            mode=MODE_RETURN,
            method_id=METHOD_CLOSE_CONNECTION,
            invoke_id=packet.invoke_id,
            err_id=0,
            payload=b"",
        )
        return [resp]
