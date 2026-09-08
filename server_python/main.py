"""
Project Mugen / Ananta (LX6) Private Server
Main Entrypoint
"""

import os
import sys
import json
import asyncio

# Ensure server directory is in sys.path
SERVER_DIR = os.path.dirname(os.path.abspath(__file__))
if SERVER_DIR not in sys.path:
    sys.path.insert(0, SERVER_DIR)

from database.player_storage import PlayerStorage
from database.config_loader import ConfigLoader
from services.login_service import LoginService
from services.gate_service import GateService
from services.game_service import GameService
from network.rpc_dispatcher import RpcDispatcher
from network.connection import TcpRpcServer
from gateway.http_server import HttpGatewayServer


def load_config():
    cfg_path = os.path.join(SERVER_DIR, "config.json")
    if os.path.exists(cfg_path):
        with open(cfg_path, "r", encoding="utf-8") as f:
            return json.load(f)
    return {
        "server": {
            "name": "Ananta Local Server",
            "host": "0.0.0.0",
            "public_ip": "127.0.0.1",
            "http_port": 8080,
            "login_port": 8888,
            "gate_port": 8888,
            "status": 0,
            "region_id": 1,
            "region_name": "Local",
        }
    }


async def main():
    config = load_config()
    server_cfg = config.get("server", {})
    host = server_cfg.get("host", "0.0.0.0")
    http_port = server_cfg.get("http_port", 8080)
    rpc_port = server_cfg.get("login_port", 8888)
    server_name = server_cfg.get("name", "Ananta Private Server")

    print("=" * 60)
    print(f"      {server_name} - Starting Up")
    print("=" * 60)

    # 1. Initialize Storage & Configs
    storage = PlayerStorage(config)
    config_loader = ConfigLoader()
    print("[Core] Player storage initialized at server/data/players/")

    # 2. Initialize Services
    login_service = LoginService(storage, config)
    gate_service = GateService(storage, config)
    game_service = GameService(storage, config)

    # 3. Initialize RPC Dispatcher
    dispatcher = RpcDispatcher(login_service, gate_service, game_service)

    # 4. Start HTTP Gateway (Web API)
    gateway = HttpGatewayServer(host, http_port, config)
    gateway.start()

    # 5. Start TCP UX RPC Server
    tcp_server = TcpRpcServer(host, rpc_port, dispatcher)
    await tcp_server.start()

    print("=" * 60)
    print(f"  [+] HTTP Gateway Server : http://127.0.0.1:{http_port}")
    print(f"  [+] UX RPC Socket Server: 127.0.0.1:{rpc_port} (TCP)")
    print("  [+] Status               : READY TO CONNECT")
    print("=" * 60)
    print("Server is running. Press Ctrl+C to stop.")

    # Keep asyncio loop running forever
    try:
        await asyncio.Event().wait()
    except (KeyboardInterrupt, asyncio.CancelledError):
        print("\nShutting down server...")
        gateway.stop()


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nServer stopped.")
