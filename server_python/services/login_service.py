"""
Login Service Handlers
Handles ClientToLoginDelegate RPCs: CheckVersion, CheckAccount, TryLogin, RequestCreateRoleEx, RequestEnterGame
"""

import time
from typing import Dict, Any, List
from network.protocol import (
    BinaryWriter,
    BinaryReader,
    RpcPacket,
    MODE_RETURN,
    MODE_NOTIFY,
    MARK_COMMON,
)
from database.player_storage import PlayerStorage

# Method IDs
METHOD_CHECK_VERSION = 34700853
METHOD_CHECK_ACCOUNT = 34339919
METHOD_CHECK_ACCOUNT_PASS_BY = 34163006
METHOD_TRY_LOGIN = 34529582
METHOD_REQUEST_CREATE_ROLE = 34383517
METHOD_REQUEST_ENTER_GAME = 34566515
METHOD_SYNC_ROLE_LIST = 35167428


class LoginService:
    def __init__(self, storage: PlayerStorage, config: Dict[str, Any]):
        self.storage = storage
        self.config = config
        self.server_cfg = config.get("server", {})

    def handle_check_version(self, packet: RpcPacket, session) -> List[RpcPacket]:
        """Client checking version compatibility."""
        reader = BinaryReader(packet.payload)
        code_md5 = reader.read_string()
        client_version = reader.read_int32() if reader.remaining >= 4 else 0
        print(f"[LoginService] CheckVersion: md5={code_md5}, version={client_version}")

        # Returns errId = 0 (OK)
        resp = RpcPacket(
            mode=MODE_RETURN,
            method_id=METHOD_CHECK_VERSION,
            invoke_id=packet.invoke_id,
            err_id=0,
            payload=b"",
        )
        return [resp]

    def handle_check_account(self, packet: RpcPacket, session) -> List[RpcPacket]:
        """Client checking account / auth token."""
        reader = BinaryReader(packet.payload)
        sauth_json = reader.read_string() if reader.remaining > 0 else "{}"
        print(f"[LoginService] CheckAccount: sauth={sauth_json}")

        resp = RpcPacket(
            mode=MODE_RETURN,
            method_id=METHOD_CHECK_ACCOUNT,
            invoke_id=packet.invoke_id,
            err_id=0,
            payload=b"",
        )
        return [resp]

    def handle_check_account_pass_by(self, packet: RpcPacket, session) -> List[RpcPacket]:
        """Client checking username directly (Editor/Cheat login)."""
        reader = BinaryReader(packet.payload)
        username = reader.read_string() if reader.remaining > 0 else "Player"
        print(f"[LoginService] CheckAccountPassBy: username={username}")
        session.account_name = username

        resp = RpcPacket(
            mode=MODE_RETURN,
            method_id=METHOD_CHECK_ACCOUNT_PASS_BY,
            invoke_id=packet.invoke_id,
            err_id=0,
            payload=b"",
        )
        return [resp]

    def handle_try_login(self, packet: RpcPacket, session) -> List[RpcPacket]:
        """Client trying to login."""
        reader = BinaryReader(packet.payload)
        aid = reader.read_int32() if reader.remaining >= 4 else 0
        token = reader.read_string() if reader.remaining > 0 else ""
        print(f"[LoginService] TryLogin: aid={aid}, token={token}")

        account_name = session.account_name or f"User_{aid}" if aid > 0 else "Player"
        player = self.storage.get_or_create_by_account(account_name)
        session.player = player

        responses = []
        # 1. Return response (errId = 0)
        ret_pkt = RpcPacket(
            mode=MODE_RETURN,
            method_id=METHOD_TRY_LOGIN,
            invoke_id=packet.invoke_id,
            err_id=0,
            payload=b"",
        )
        responses.append(ret_pkt)

        # 2. Server Push: SyncRoleList (35167428) -> sends pid (uint64)
        role_pid = player.get("pid", 1000000001)
        w = BinaryWriter()
        w.write_uint64(role_pid)
        sync_pkt = RpcPacket(
            mode=MODE_NOTIFY,
            method_id=METHOD_SYNC_ROLE_LIST,
            payload=w.get_bytes(),
        )
        responses.append(sync_pkt)
        print(f"[LoginService] Sent SyncRoleList with pid={role_pid}")

        return responses

    def handle_request_create_role(self, packet: RpcPacket, session) -> List[RpcPacket]:
        """Client creating a character if role list was empty."""
        account_name = session.account_name or "Player"
        player = self.storage.get_or_create_by_account(account_name)
        role_pid = player.get("pid", 1000000001)
        print(f"[LoginService] RequestCreateRole: assigning pid={role_pid}")

        w = BinaryWriter()
        w.write_uint64(role_pid)
        ret_pkt = RpcPacket(
            mode=MODE_RETURN,
            method_id=METHOD_REQUEST_CREATE_ROLE,
            invoke_id=packet.invoke_id,
            err_id=0,
            payload=w.get_bytes(),
        )
        return [ret_pkt]

    def handle_request_enter_game(self, packet: RpcPacket, session) -> List[RpcPacket]:
        """Client requesting to enter game: return Gate info."""
        player = session.player
        if not player:
            player = self.storage.get_or_create_by_account(session.account_name or "Player")
            session.player = player

        aid = player.get("aid", 10001)
        pid = player.get("pid", 1000000001)
        public_ip = self.server_cfg.get("public_ip", "127.0.0.1")
        gate_port = self.server_cfg.get("gate_port", 8888)
        token = player.get("token", "default_token")

        print(f"[LoginService] RequestEnterGame: directing to Gate {public_ip}:{gate_port}")

        # Serializes Auto.Reader[580]:
        # obj.Aid = reader.ReadInt32()
        # obj.Pid = reader.ReadUInt64()
        # obj.Token = Base.ReadComplex(Auto.Reader[1573])
        # Auto.Reader[1573]:
        #   Aid (int32)
        #   Pid (uint64)
        #   Ip (string)
        #   Port (int32)
        #   Token (string)
        #   GateServerId (int32)
        #   AccountId (string)

        w = BinaryWriter()
        # Top-level struct Reader[580]
        w.write_int32(aid)
        w.write_uint64(pid)

        # Complex Token Reader[1573]
        w.write_byte(MARK_COMMON)  # Object not null
        w.write_int32(aid)
        w.write_uint64(pid)
        w.write_string(public_ip)
        w.write_int32(gate_port)
        w.write_string(token)
        w.write_int32(1)  # GateServerId
        w.write_string(player.get("account", "Player"))

        ret_pkt = RpcPacket(
            mode=MODE_RETURN,
            method_id=METHOD_REQUEST_ENTER_GAME,
            invoke_id=packet.invoke_id,
            err_id=0,
            payload=w.get_bytes(),
        )
        return [ret_pkt]
