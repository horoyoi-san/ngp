using System;
using System.IO;
using System.Net;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace AnantaServer.Gateway
{
    public class HttpGateway
    {
        private readonly HttpListener _listener;
        private readonly int _port;
        private readonly string _serverName;
        private readonly string _publicIp;
        private readonly int _rpcPort;
        private bool _running;

        public HttpGateway(int port = 8080, string serverName = "Ananta C# Server", string publicIp = "127.0.0.1", int rpcPort = 8888)
        {
            _port = port;
            _serverName = serverName;
            _publicIp = publicIp;
            _rpcPort = rpcPort;
            _listener = new HttpListener();
            _listener.Prefixes.Add($"http://localhost:{port}/");
            _listener.Prefixes.Add($"http://127.0.0.1:{port}/");
        }

        public void Start()
        {
            try
            {
                _listener.Start();
                _running = true;
                Task.Run(ListenLoop);
                Console.WriteLine($"[C# HttpGateway] REST API listening on http://127.0.0.1:{_port}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[C# HttpGateway] Warning: could not start HttpListener: {ex.Message}");
            }
        }

        public void Stop()
        {
            _running = false;
            _listener.Stop();
        }

        private async Task ListenLoop()
        {
            while (_running)
            {
                try
                {
                    var ctx = await _listener.GetContextAsync();
                    _ = ProcessRequest(ctx);
                }
                catch when (!_running) { break; }
                catch (Exception ex)
                {
                    Console.WriteLine($"[C# HttpGateway] Error: {ex.Message}");
                }
            }
        }

        private async Task ProcessRequest(HttpListenerContext ctx)
        {
            var req = ctx.Request;
            var res = ctx.Response;
            string path = req.Url?.AbsolutePath.ToLowerInvariant() ?? "/";

            Console.WriteLine($"[C# HTTP] {req.HttpMethod} {path}");

            if (path == "/" || path == "/index" || path == "/status")
            {
                string html = $@"<!DOCTYPE html>
<html>
<head><meta charset='utf-8'><title>{_serverName}</title>
<style>body{{font-family:Segoe UI,sans-serif;background:#0f172a;color:#f8fafc;padding:40px;}}
.card{{background:#1e293b;border-radius:12px;padding:24px;max-width:600px;margin:0 auto;}}
h1{{color:#38bdf8;margin-top:0;}}
.badge{{background:#22c55e;color:#000;padding:4px 10px;border-radius:99px;font-weight:bold;}}</style>
</head>
<body>
<div class='card'>
    <h1>🎮 {_serverName} (.NET 9 C#)</h1>
    <p><span class='badge'>ONLINE</span> High Performance C# Server</p>
    <p>UX RPC Socket: <b>{_publicIp}:{_rpcPort}</b></p>
</div>
</body></html>";
                byte[] htmlBytes = Encoding.UTF8.GetBytes(html);
                res.ContentType = "text/html; charset=utf-8";
                res.ContentLength64 = htmlBytes.Length;
                await res.OutputStream.WriteAsync(htmlBytes);
                res.Close();
                return;
            }

            object responseObj;
            if (path.Contains("server_list") || path.Contains("gateway"))
            {
                responseObj = new
                {
                    code = 200,
                    msg = "success",
                    servers = new[]
                    {
                        new {
                            id = 1,
                            name = _serverName,
                            ip = _publicIp,
                            port = _rpcPort,
                            status = 0
                        }
                    }
                };
            }
            else if (path.Contains("unisdk") || path.Contains("login") || path.Contains("auth"))
            {
                responseObj = new
                {
                    code = 200,
                    msg = "success",
                    aid = 10001,
                    token = "token_csharp_mock",
                    uid = "1000000001",
                    user_id = "player_csharp"
                };
            }
            else
            {
                responseObj = new { code = 200, status = 0, msg = "ok" };
            }

            string json = JsonSerializer.Serialize(responseObj, new JsonSerializerOptions { WriteIndented = true });
            byte[] bytes = Encoding.UTF8.GetBytes(json);
            res.ContentType = "application/json; charset=utf-8";
            res.AddHeader("Access-Control-Allow-Origin", "*");
            res.ContentLength64 = bytes.Length;
            await res.OutputStream.WriteAsync(bytes);
            res.Close();
        }
    }
}
