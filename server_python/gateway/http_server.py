"""
HTTP Gateway & Dispatch Server
Provides REST endpoints for SDK login mock, server list, and status page.
"""

import json
from http.server import HTTPServer, BaseHTTPRequestHandler
import threading
from typing import Dict, Any


class GatewayRequestHandler(BaseHTTPRequestHandler):
    config: Dict[str, Any] = {}

    def log_message(self, format, *args):
        # Clean logging
        print(f"[HTTP] {self.command} {self.path} - {args[0] if args else ''}")

    def _send_json(self, data: Any, status: int = 200):
        body = json.dumps(data, ensure_ascii=False, indent=2).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _send_html(self, html: str, status: int = 200):
        body = html.encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = self.path.split("?")[0].lower()
        server_cfg = self.config.get("server", {})
        public_ip = server_cfg.get("public_ip", "127.0.0.1")
        rpc_port = server_cfg.get("login_port", 8888)
        server_name = server_cfg.get("name", "Local Private Server")

        if path in ("/", "/index", "/status"):
            html = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Ananta / Project Mugen Private Server</title>
    <style>
        body {{ font-family: 'Segoe UI', Tahoma, sans-serif; background: #0f172a; color: #f8fafc; padding: 40px; }}
        .card {{ background: #1e293b; border-radius: 12px; padding: 24px; max-width: 600px; margin: 0 auto; box-shadow: 0 4px 20px rgba(0,0,0,0.5); }}
        h1 {{ color: #38bdf8; margin-top: 0; }}
        .status {{ display: inline-block; padding: 4px 12px; background: #22c55e; color: #000; border-radius: 9999px; font-weight: bold; font-size: 14px; }}
        table {{ width: 100%; border-collapse: collapse; margin-top: 20px; }}
        td {{ padding: 10px 0; border-bottom: 1px solid #334155; }}
        td:first-child {{ color: #94a3b8; font-weight: 500; }}
        code {{ background: #0f172a; padding: 2px 6px; border-radius: 4px; color: #f43f5e; }}
    </style>
</head>
<body>
    <div class="card">
        <h1>🎮 {server_name}</h1>
        <p><span class="status">● ONLINE</span> เซิร์ฟเวอร์ทำงานปกติ พร้อมรับการเชื่อมต่อ</p>
        <table>
            <tr><td>HTTP Gateway</td><td><code>http://{public_ip}:{server_cfg.get('http_port', 8080)}</code></td></tr>
            <tr><td>UX RPC Socket</td><td><code>{public_ip}:{rpc_port} (TCP)</code></td></tr>
            <tr><td>Region</td><td>{server_cfg.get('region_name', 'Local')}</td></tr>
            <tr><td>API Endpoints</td><td><code>/server_list</code>, <code>/unisdk/login</code></td></tr>
        </table>
    </div>
</body>
</html>"""
            self._send_html(html)

        elif path in ("/server_list", "/query_gateway", "/gateway", "/api/servers"):
            data = {
                "code": 200,
                "msg": "success",
                "servers": [
                    {
                        "id": server_cfg.get("region_id", 1),
                        "name": server_name,
                        "ip": public_ip,
                        "port": rpc_port,
                        "status": server_cfg.get("status", 0),
                    }
                ],
            }
            self._send_json(data)

        elif "unisdk" in path or "login" in path or "auth" in path:
            data = {
                "code": 200,
                "msg": "success",
                "aid": 10001,
                "token": "token_local_mock",
                "uid": "1000000001",
                "user_id": "player_test",
            }
            self._send_json(data)

        else:
            self._send_json({"code": 200, "status": 0, "msg": "ok"})

    def do_POST(self):
        # Handle POST requests (like SDK login tokens) identically
        self.do_GET()


class HttpGatewayServer:
    def __init__(self, host: str, port: int, config: Dict[str, Any]):
        self.host = host
        self.port = port
        self.config = config
        self.server = None
        self.thread = None

    def start(self):
        GatewayRequestHandler.config = self.config
        self.server = HTTPServer((self.host, self.port), GatewayRequestHandler)
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        print(f"[HttpGatewayServer] Gateway REST API listening on http://{self.host}:{self.port}")

    def stop(self):
        if self.server:
            self.server.shutdown()
