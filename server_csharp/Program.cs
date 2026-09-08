using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Threading.Tasks;
using AnantaServer.Gateway;
using AnantaServer.Network;
using AnantaServer.Services;

namespace AnantaServer
{
    internal class Program
    {
        private static async Task Main(string[] args)
        {
            Console.OutputEncoding = System.Text.Encoding.UTF8;
            Console.Title = "Ananta Private Server (.NET 9 C#)";

            const int httpPort = 8080;
            const int rpcPort = 8888;
            const string host = "127.0.0.1";

            Console.WriteLine("============================================================");
            Console.WriteLine("      Ananta Private Server (.NET 9 C#) - Starting Up       ");
            Console.WriteLine("============================================================");

            var loginService = new LoginService();
            var gateService = new GateService();

            // 1. Start HTTP Gateway
            var gateway = new HttpGateway(httpPort, "Ananta C# Server", host, rpcPort);
            gateway.Start();

            // 2. Start TCP Listener for UX RPC
            var tcpListener = new TcpListener(IPAddress.Any, rpcPort);
            tcpListener.Start();

            Console.WriteLine("============================================================");
            Console.WriteLine($"  [+] HTTP Gateway Server : http://127.0.0.1:{httpPort}");
            Console.WriteLine($"  [+] UX RPC Socket Server: 127.0.0.1:{rpcPort} (TCP)");
            Console.WriteLine("  [+] Runtime             : .NET 9.0 (C#)");
            Console.WriteLine("  [+] Status              : READY TO CONNECT");
            Console.WriteLine("============================================================");
            Console.WriteLine("Server running. Press Ctrl+C to exit.");

            while (true)
            {
                try
                {
                    var client = await tcpListener.AcceptTcpClientAsync();
                    _ = HandleClientAsync(client, loginService, gateService, host, rpcPort);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[TCP Server Error] {ex.Message}");
                }
            }
        }

        private static async Task HandleClientAsync(TcpClient client, LoginService loginService, GateService gateService, string host, int rpcPort)
        {
            var ep = client.Client.RemoteEndPoint;
            Console.WriteLine($"[C# TCP] Client connected: {ep}");

            using var stream = client.GetStream();
            byte[] lengthBuffer = new byte[4];

            try
            {
                while (client.Connected)
                {
                    // Read 4-byte length prefix
                    int read = await ReadExactAsync(stream, lengthBuffer, 4);
                    if (read == 0) break;

                    uint packetLength = BitConverter.ToUInt32(lengthBuffer, 0);
                    if (packetLength > 10 * 1024 * 1024)
                    {
                        Console.WriteLine($"[C# TCP] Packet too large ({packetLength}), disconnecting");
                        break;
                    }

                    byte[] packetData = new byte[packetLength];
                    await ReadExactAsync(stream, packetData, (int)packetLength);

                    var packet = RpcPacket.Decode(packetData);
                    Console.WriteLine($"[C# RPC In] MethodId: {packet.MethodId}, InvokeId: {packet.InvokeId}, Mode: {packet.Mode}");

                    // Route packet
                    var responses = packet.MethodId switch
                    {
                        LoginService.MethodCheckVersion => loginService.HandleCheckVersion(packet),
                        LoginService.MethodCheckAccount => loginService.HandleCheckAccount(packet),
                        LoginService.MethodCheckAccountPassBy => loginService.HandleCheckAccountPassBy(packet),
                        LoginService.MethodTryLogin => loginService.HandleTryLogin(packet, 1000000001),
                        LoginService.MethodRequestCreateRole => loginService.HandleRequestCreateRole(packet, 1000000001),
                        LoginService.MethodRequestEnterGame => loginService.HandleRequestEnterGame(packet, 10001, 1000000001, host, rpcPort, "token_csharp"),
                        GateService.MethodGateLogin => gateService.HandleGateLogin(packet),
                        GateService.MethodGetServerTime => gateService.HandleGetServerTime(packet),
                        _ => new System.Collections.Generic.List<RpcPacket>
                        {
                            // Generic fallback for any other RPC
                            new RpcPacket(PacketModes.Return, packet.MethodId, packet.InvokeId, errId: 0)
                        }
                    };

                    foreach (var resp in responses)
                    {
                        byte[] responseBytes = resp.Encode(includeFraming: true);
                        await stream.WriteAsync(responseBytes);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[C# TCP] Client {ep} connection closed ({ex.Message})");
            }
            finally
            {
                client.Close();
            }
        }

        private static async Task<int> ReadExactAsync(NetworkStream stream, byte[] buffer, int count)
        {
            int totalRead = 0;
            while (totalRead < count)
            {
                int read = await stream.ReadAsync(buffer, totalRead, count - totalRead);
                if (read == 0) return totalRead;
                totalRead += read;
            }
            return totalRead;
        }
    }
}
