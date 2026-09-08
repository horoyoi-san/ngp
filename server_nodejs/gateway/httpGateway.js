const http = require("http");

class HttpGateway {
    constructor(port = 8080, serverName = "Ananta Node.js Server", publicIp = "127.0.0.1", rpcPort = 8888) {
        this.port = port;
        this.serverName = serverName;
        this.publicIp = publicIp;
        this.rpcPort = rpcPort;
        this.server = null;
    }

    start() {
        this.server = http.createServer((req, res) => {
            const urlPath = (req.url || "/").split("?")[0].toLowerCase();
            console.log(`[Node.js HTTP] ${req.method} ${urlPath}`);

            if (urlPath === "/" || urlPath === "/index" || urlPath === "/status") {
                const html = `<!DOCTYPE html>
<html>
<head><meta charset='utf-8'><title>${this.serverName}</title>
<style>body{font-family:Segoe UI,sans-serif;background:#0f172a;color:#f8fafc;padding:40px;}
.card{background:#1e293b;border-radius:12px;padding:24px;max-width:600px;margin:0 auto;}
h1{color:#38bdf8;margin-top:0;}
.badge{background:#22c55e;color:#000;padding:4px 10px;border-radius:99px;font-weight:bold;}</style>
</head>
<body>
<div class='card'>
    <h1>🎮 ${this.serverName} (Node.js)</h1>
    <p><span class='badge'>ONLINE</span> Node.js UX RPC Server</p>
    <p>UX RPC Socket: <b>${this.publicIp}:${this.rpcPort}</b></p>
</div>
</body></html>`;
                res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
                res.end(html);
                return;
            }

            let responseData;
            if (urlPath.includes("server_list") || urlPath.includes("gateway")) {
                responseData = {
                    code: 200,
                    msg: "success",
                    servers: [
                        {
                            id: 1,
                            name: this.serverName,
                            ip: this.publicIp,
                            port: this.rpcPort,
                            status: 0,
                        },
                    ],
                };
            } else if (urlPath.includes("unisdk") || urlPath.includes("login") || urlPath.includes("auth")) {
                responseData = {
                    code: 200,
                    msg: "success",
                    aid: 10001,
                    token: "token_nodejs_mock",
                    uid: "1000000001",
                    user_id: "player_nodejs",
                };
            } else {
                responseData = { code: 200, status: 0, msg: "ok" };
            }

            const json = JSON.stringify(responseData, null, 2);
            res.writeHead(200, {
                "Content-Type": "application/json; charset=utf-8",
                "Access-Control-Allow-Origin": "*",
            });
            res.end(json);
        });

        this.server.listen(this.port, () => {
            console.log(`[Node.js HttpGateway] REST API listening on http://127.0.0.1:${this.port}`);
        });
    }

    stop() {
        if (this.server) {
            this.server.close();
        }
    }
}

module.exports = { HttpGateway };
