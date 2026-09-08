"""
Game & Scene Service Handlers
Handles general gameplay and unhandled RPCs gracefully.
"""

from typing import Dict, Any, List
from network.protocol import RpcPacket, MODE_RETURN
from database.player_storage import PlayerStorage


class GameService:
    def __init__(self, storage: PlayerStorage, config: Dict[str, Any]):
        self.storage = storage
        self.config = config

    def handle_default(self, packet: RpcPacket, session, method_name: str = "") -> List[RpcPacket]:
        """Default fallback handler for unknown or unimplemented RPCs to keep client running smoothly."""
        print(f"[GameService] Handled generic RPC [{method_name or packet.method_id}] invokeId={packet.invoke_id}")
        if packet.invoke_id > 0:
            resp = RpcPacket(
                mode=MODE_RETURN,
                method_id=packet.method_id,
                invoke_id=packet.invoke_id,
                err_id=0,
                payload=b"",
            )
            return [resp]
        return []
