
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using AnantaTestGameServer.Methods.Return;
using AnantaTestGameServer.Packets.Req;
using AnantaTestGameServer.Messages; // Adicionado para UxRpcMessage
using UX.RPC.Protocol; // Adicionado para MethodId
using AnantaTestGameServer.Configs;

namespace AnantaTestGameServer
{
    public partial class Server
    {


        public static Server Instance;
        public List<Connection> Connections = new List<Connection>();

        public void Start()
        {
            Instance = this;
            Logger.Initialize(false);
            string configDir = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "configs");
            ConfigManager.LoadAll(configDir);
            GameConfig.Load(configDir);
            DestructibleObjectManager.SpawnCityObjects();

            // Load real scene item placement data from extracted world data
            string extractedWorldData = Path.GetFullPath(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "..", "..", "..", "..", "extracted", "world_data"));
            if (Directory.Exists(extractedWorldData))
            {
                Game.SceneItemPlacementLoader.Load(extractedWorldData);
            }
            else
            {
                Console.WriteLine($"[Server] Extracted world data not found at: {extractedWorldData}");
            }

            {
                Assembly assembly = Assembly.GetExecutingAssembly();
                Type[] types = assembly.GetTypes();

                foreach (var type in types)
                {
                    NotifyManager.AddReqGroupHandler(type);
                }

                NotifyManager.Init();
                
            }
            int[] ports = GameConfig.GamePorts;

            foreach (int port in ports)
            {
                var socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
                socket.Bind(new IPEndPoint(IPAddress.Any, port));
                
                socket.Listen(100);
                new Thread(() =>
                {
                    HandleConnections(socket,port);
                }).Start();
                Console.WriteLine($"Listening on port {port}");
            }
            Console.WriteLine($"Server in ascolto sulle porte 5200, 5201, 5202...");
            StartGmToolServer();
            
            // Initialize debug logger to ensure log file is created
            Game.DebugLogger.Log("Server starting - DebugLogger initialized");

            Game.GameTickService.Start();
            Game.MemoryManager.Start();
            LoginListDispatch.Start();


        }
        public async void RemoveConnection(Connection conn)
        {
            lock (Connections)
            {
                Connections.Remove(conn);
            }
        }
        public void HandleConnections(Socket ServerSocket, int Port)
        {
            while (true)
            {
                Socket Client = ServerSocket.Accept();
                int sessionId = GameSessionTracker.OnConnected(Client);
                Connection conn = new Connection(Client, sessionId);
                lock (Connections)
                {
                    Connections.Add(conn);
                }
                Console.WriteLine("Connected new Client to Port: "+Port+": " + Client.RemoteEndPoint);
            }
        }

        private void StartGmToolServer()
        {
            try
            {
                TcpListener listener = new TcpListener(IPAddress.Loopback, GameConfig.GmToolPort);
                listener.Start();
                new Thread(() => HandleGmToolRequests(listener))
                {
                    IsBackground = true
                }.Start();
                Console.WriteLine($"[GM] Vehicle tool listening on http://127.0.0.1:{GameConfig.GmToolPort}/");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[GM] Failed to start vehicle tool: {ex.Message}");
            }
        }

        private void HandleGmToolRequests(TcpListener listener)
        {
            while (true)
            {
                try
                {
                    using TcpClient client = listener.AcceptTcpClient();
                    HandleGmToolRequest(client);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[GM] Request error: {ex.Message}");
                }
            }
        }

        private void HandleGmToolRequest(TcpClient client)
        {
            using NetworkStream stream = client.GetStream();
            using StreamReader reader = new StreamReader(stream, Encoding.ASCII, leaveOpen: true);
            string? requestLine = reader.ReadLine();
            if (string.IsNullOrWhiteSpace(requestLine))
                return;

            while (!string.IsNullOrEmpty(reader.ReadLine()))
            {
            }

            string[] parts = requestLine.Split(' ');
            if (parts.Length < 2)
            {
                WriteGmHttpResponse(stream, 400, "Bad request");
                return;
            }

            string response = DispatchGmToolRequest(parts[1], out int statusCode, out string contentType);
            WriteGmHttpResponse(stream, statusCode, response, contentType);
        }

        // ── Utilities ──────────────────────────────────────────────

        private Connection? GetActiveConnection()
        {
            lock (Connections)
            {
                return Connections.LastOrDefault(c => c.Pid != 0) ?? Connections.LastOrDefault();
            }
        }

        private static Dictionary<string, string> ParseQuery(string query)
        {
            Dictionary<string, string> result = new(StringComparer.OrdinalIgnoreCase);
            if (string.IsNullOrWhiteSpace(query))
                return result;

            foreach (string pair in query.TrimStart('?').Split('&', StringSplitOptions.RemoveEmptyEntries))
            {
                string[] kv = pair.Split('=', 2);
                string key = Uri.UnescapeDataString(kv[0]);
                string value = kv.Length > 1 ? Uri.UnescapeDataString(kv[1]) : "";
                result[key] = value;
            }

            return result;
        }

        private static uint GetQueryUInt(Dictionary<string, string> query, string name, uint fallback)
        {
            return query.TryGetValue(name, out string? value) && uint.TryParse(value, out uint parsed)
                ? parsed
                : fallback;
        }

        private static ulong GetQueryULong(Dictionary<string, string> query, string name, ulong fallback)
        {
            return query.TryGetValue(name, out string? value) && ulong.TryParse(value, out ulong parsed)
                ? parsed
                : fallback;
        }

        private static double GetQueryDouble(Dictionary<string, string> query, string name, double fallback)
        {
            return query.TryGetValue(name, out string? value) && double.TryParse(value, out double parsed)
                ? parsed
                : fallback;
        }

        private static float? GetQueryFloat(Dictionary<string, string> query, string name)
        {
            return query.TryGetValue(name, out string? value) && float.TryParse(value, out float parsed)
                ? parsed
                : null;
        }

        private static UXVector3? TryBuildQueryPosition(Dictionary<string, string> query)
        {
            float? x = GetQueryFloat(query, "x");
            float? y = GetQueryFloat(query, "y");
            float? z = GetQueryFloat(query, "z");
            if (x == null || y == null || z == null)
                return null;

            return new UXVector3()
            {
                X = x.Value,
                Y = y.Value,
                Z = z.Value
            };
        }

        private static void WriteGmHttpResponse(NetworkStream stream, int statusCode, string body, string contentType = "text/plain; charset=utf-8")
        {
            string reason = statusCode == 200 ? "OK" : statusCode == 404 ? "Not Found" : "Error";
            byte[] bodyBytes = Encoding.UTF8.GetBytes(body);
            string header =
                $"HTTP/1.1 {statusCode} {reason}\r\n" +
                $"Content-Type: {contentType}\r\n" +
                $"Content-Length: {bodyBytes.Length}\r\n" +
                "Connection: close\r\n\r\n";
            byte[] headerBytes = Encoding.ASCII.GetBytes(header);
            stream.Write(headerBytes, 0, headerBytes.Length);
            stream.Write(bodyBytes, 0, bodyBytes.Length);
        }
    }
}
