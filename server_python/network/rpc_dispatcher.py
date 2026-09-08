"""
RPC Dispatcher
Routes incoming UX RPC packets by methodId to the appropriate service handler.
"""

import os
import re
from typing import Dict, Any, List, Callable
from network.protocol import RpcPacket, MODE_INVOKE, MODE_NOTIFY
from services.login_service import (
    LoginService,
    METHOD_CHECK_VERSION,
    METHOD_CHECK_ACCOUNT,
    METHOD_CHECK_ACCOUNT_PASS_BY,
    METHOD_TRY_LOGIN,
    METHOD_REQUEST_CREATE_ROLE,
    METHOD_REQUEST_ENTER_GAME,
)
from services.gate_service import (
    GateService,
    METHOD_GATE_LOGIN,
    METHOD_GET_SERVER_TIME,
    METHOD_REPORT_NETWORK_QUALITY,
    METHOD_CLOSE_CONNECTION,
)
from services.game_service import GameService


class RpcDispatcher:
    def __init__(
        self,
        login_service: LoginService,
        gate_service: GateService,
        game_service: GameService,
    ):
        self.login_service = login_service
        self.gate_service = gate_service
        self.game_service = game_service

        self.method_names: Dict[int, str] = {}
        self.handlers: Dict[int, Callable] = {}
        self._load_method_names()
        self._register_handlers()

    def _load_method_names(self):
        """Loads method names from LuaGen/AutoGen/RPCMethodIdToName.lua if present."""
        lua_path = os.path.abspath(
            os.path.join(
                os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
                "lua",
                "lua",
                "LuaGen",
                "AutoGen",
                "RPCMethodIdToName.lua",
            )
        )
        if os.path.exists(lua_path):
            try:
                pattern = re.compile(r"\[(\d+)\]\s*=\s*\"([^\"]+)\"")
                with open(lua_path, "r", encoding="utf-8", errors="ignore") as f:
                    for line in f:
                        m = pattern.search(line)
                        if m:
                            mid = int(m.group(1))
                            name = m.group(2)
                            self.method_names[mid] = name
                print(f"[RpcDispatcher] Loaded {len(self.method_names)} RPC definitions from LuaGen.")
            except Exception as e:
                print(f"[RpcDispatcher] Warning: could not load RPCMethodIdToName.lua: {e}")

    def _register_handlers(self):
        # Login handlers
        self.handlers[METHOD_CHECK_VERSION] = self.login_service.handle_check_version
        self.handlers[METHOD_CHECK_ACCOUNT] = self.login_service.handle_check_account
        self.handlers[METHOD_CHECK_ACCOUNT_PASS_BY] = self.login_service.handle_check_account_pass_by
        self.handlers[METHOD_TRY_LOGIN] = self.login_service.handle_try_login
        self.handlers[METHOD_REQUEST_CREATE_ROLE] = self.login_service.handle_request_create_role
        self.handlers[METHOD_REQUEST_ENTER_GAME] = self.login_service.handle_request_enter_game

        # Gate handlers
        self.handlers[METHOD_GATE_LOGIN] = self.gate_service.handle_gate_login
        self.handlers[METHOD_GET_SERVER_TIME] = self.gate_service.handle_get_server_time
        self.handlers[METHOD_REPORT_NETWORK_QUALITY] = self.gate_service.handle_report_network_quality
        self.handlers[METHOD_CLOSE_CONNECTION] = self.gate_service.handle_close_connection

    def dispatch(self, packet: RpcPacket, session) -> List[RpcPacket]:
        method_name = self.method_names.get(packet.method_id, f"RPC_{packet.method_id}")
        mode_str = "INVOKE" if packet.mode == MODE_INVOKE else "NOTIFY" if packet.mode == MODE_NOTIFY else "RETURN"
        print(f"[RPC] In [{mode_str}] {method_name} (ID: {packet.method_id}, InvokeID: {packet.invoke_id})")

        handler = self.handlers.get(packet.method_id)
        if handler:
            try:
                responses = handler(packet, session)
                return responses
            except Exception as e:
                print(f"[RPC] Error in handler for {method_name}: {e}")
                import traceback

                traceback.print_exc()

        # Fallback to game service
        return self.game_service.handle_default(packet, session, method_name)
