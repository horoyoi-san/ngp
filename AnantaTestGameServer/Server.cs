using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using System.IO;
using Newtonsoft.Json;

namespace AnantaTestGameServer
{
    public class Server
    {
        public static Server Instance;
        public List<Connection> Connections = new List<Connection>();

        private HttpListener httpListener;

        // Dicionário para armazenar informações de patch
        public Dictionary<long, ulong> PatchInfo { get; private set; }

        public void Start()
        {
            Instance = this;
            Logger.Initialize(false);
            
            // Inicializar dicionário de informações de patch
            PatchInfo = new Dictionary<long, ulong>();
            
            // Carregar informações de patch do arquivo
            string patchInfoPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "trunk-client_startup_patch_info.txt");
            LoadPatchInfo(patchInfoPath);

            {
                Assembly assembly = Assembly.GetExecutingAssembly();
                Type[] types = assembly.GetTypes();

                foreach (var type in types)
                {
                    NotifyManager.AddReqGroupHandler(type);
                }

                NotifyManager.Init();
            }

            // Iniciar o listener HTTP para o gateway control
            StartHttpListener();

            int[] ports = { 5200, 5201, 5202 };

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
            Console.WriteLine($"Server listening on ports 5200, 5201, 5202...");
            LoginListDispatch.Start();
        }

        public void LoadPatchInfo(string filePath)
        {
            if (!File.Exists(filePath))
            {
                Console.WriteLine($"Arquivo de informações de patch não encontrado: {filePath}");
                return;
            }

            try
            {
                string[] lines = File.ReadAllLines(filePath);
                foreach (string line in lines)
                {
                    if (string.IsNullOrWhiteSpace(line)) continue;

                    string[] parts = line.Split(':');
                    if (parts.Length == 2 && long.TryParse(parts[0], out long id) && ulong.TryParse(parts[1], out ulong size))
                    {
                        PatchInfo[id] = size;
                    }
                }

                Console.WriteLine($"Carregadas {PatchInfo.Count} entradas de informações de patch");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Erro ao carregar informações de patch: {ex.Message}");
            }
        }

        public bool TryGetPatchSize(long patchId, out ulong size)
        {
            return PatchInfo.TryGetValue(patchId, out size);
        }

        private void StartHttpListener()
        {
            try
            {
                httpListener = new HttpListener();
                // Usa Prefixes.Add com wildcard para reduzir conflitos de registro do HTTP.sys
                // (quando o prefix exato já está registrado por outro processo/instância).
                httpListener.Prefixes.Add("http://*:9011/"); // Porta padrão para o gateway control
                httpListener.Start();

                Console.WriteLine("HTTP Listener started on http://127.0.0.1:9011");

                // Começar a escutar por requisições
                ThreadPool.QueueUserWorkItem((_) =>
                {
                    try
                    {
                        while (httpListener.IsListening)
                        {
                            var context = httpListener.GetContext();
                            ProcessRequest(context);
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"HTTP Listener error: {ex.Message}");
                    }
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to start HTTP listener: {ex.Message}");
                Console.WriteLine("Make sure you're running as administrator and the port is not in use.");
            }
        }

        private void ProcessRequest(HttpListenerContext context)
        {
            var request = context.Request;
            var response = context.Response;

            try
            {
                if (request.HttpMethod == "POST" && request.Url.AbsolutePath == "/command")
                {
                    HandleCommandRequest(request, response);
                }
                else if (request.HttpMethod == "POST" && request.Url.AbsolutePath == "/spawn")
                {
                    HandleSpawnRequest(request, response);
                }
                else
                {
                    response.StatusCode = 404;
                    string responseString = "{\"status\":\"error\",\"message\":\"Endpoint not found\"}";
                    byte[] buffer = System.Text.Encoding.UTF8.GetBytes(responseString);
                    response.ContentLength64 = buffer.Length;
                    response.ContentType = "application/json";
                    var output = response.OutputStream;
                    output.Write(buffer, 0, buffer.Length);
                    output.Close();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error processing request: {ex.Message}");
                response.StatusCode = 500;
                string responseString = "{\"status\":\"error\",\"message\":\"Internal server error\"}";
                byte[] buffer = System.Text.Encoding.UTF8.GetBytes(responseString);
                response.ContentLength64 = buffer.Length;
                response.ContentType = "application/json";
                var output = response.OutputStream;
                output.Write(buffer, 0, buffer.Length);
                output.Close();
            }
        }

        private void HandleCommandRequest(HttpListenerRequest request, HttpListenerResponse response)
        {
            try
            {
                // Ler o corpo da requisição
                string requestBody;
                using (var reader = new StreamReader(request.InputStream, request.ContentEncoding))
                {
                    requestBody = reader.ReadToEnd();
                }

                // Converter o JSON para um objeto dinâmico
                dynamic requestData = JsonConvert.DeserializeObject(requestBody);
                int methodId = (int)requestData.methodId;

                // Enviar o comando para todas as conexões ativas
                int successfulSends = 0;
                foreach (var connection in Connections.ToList())
                {
                    try
                    {
                        // Criar uma mensagem RPC com base no methodId e nos parâmetros
                        var rpcMessage = new Messages.UxRpcMessage
                        {
                            Mode = Messages.UxRpcPacketMode.Invoke,
                            RpcMethodId = methodId
                        };

                        // Configurar os argumentos com base no requestData
                        // Esta é uma implementação genérica - cada comando específico precisaria de tratamento especial
                        connection.SendPacket(rpcMessage);
                        successfulSends++;
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error sending command to connection: {ex.Message}");
                    }
                }

                // Responder com sucesso
                string responseString = $"{{\"status\":\"success\",\"message\":\"Command sent to {successfulSends} connections\"}}";
                byte[] buffer = System.Text.Encoding.UTF8.GetBytes(responseString);
                response.ContentLength64 = buffer.Length;
                response.ContentType = "application/json";
                var output = response.OutputStream;
                output.Write(buffer, 0, buffer.Length);
                output.Close();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in HandleCommandRequest: {ex.Message}");
                response.StatusCode = 500;
                string responseString = "{\"status\":\"error\",\"message\":\"Failed to process command request\"}";
                byte[] buffer = System.Text.Encoding.UTF8.GetBytes(responseString);
                response.ContentLength64 = buffer.Length;
                response.ContentType = "application/json";
                var output = response.OutputStream;
                output.Write(buffer, 0, buffer.Length);
                output.Close();
            }
        }

        private void HandleSpawnRequest(HttpListenerRequest request, HttpListenerResponse response)
        {
            try
            {
                // Ler o corpo da requisição
                string requestBody;
                using (var reader = new StreamReader(request.InputStream, request.ContentEncoding))
                {
                    requestBody = reader.ReadToEnd();
                }

                // Converter o JSON para um objeto dinâmico
                dynamic requestData = JsonConvert.DeserializeObject(requestBody);
                int methodId = (int)requestData.methodId; // O ID do método para spawn de veículo

                // Encontrar a conexão do jogador (neste caso, usando a primeira conexão disponível)
                int successfulSends = 0;
                if (Connections.Count > 0)
                {
                    var connection = Connections.First(); // Usando a primeira conexão como exemplo
                    try
                    {
                        // Criar uma mensagem RPC para spawn de veículo
                        var rpcMessage = new Messages.UxRpcMessage
                        {
                            Mode = Messages.UxRpcPacketMode.Invoke,
                            RpcMethodId = methodId
                        };

                        // Configurar os argumentos para spawn de veículo
                        // Esta é uma implementação genérica - o spawn real dependeria da estrutura específica do método
                        connection.SendPacket(rpcMessage);
                        successfulSends++;
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error spawning vehicle: {ex.Message}");
                    }
                }

                // Responder com sucesso
                string responseString = $"{{\"status\":\"success\",\"message\":\"Spawn request processed for {successfulSends} connections\"}}";
                byte[] buffer = System.Text.Encoding.UTF8.GetBytes(responseString);
                response.ContentLength64 = buffer.Length;
                response.ContentType = "application/json";
                var output = response.OutputStream;
                output.Write(buffer, 0, buffer.Length);
                output.Close();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in HandleSpawnRequest: {ex.Message}");
                response.StatusCode = 500;
                string responseString = "{\"status\":\"error\",\"message\":\"Failed to process spawn request\"}";
                byte[] buffer = System.Text.Encoding.UTF8.GetBytes(responseString);
                response.ContentLength64 = buffer.Length;
                response.ContentType = "application/json";
                var output = response.OutputStream;
                output.Write(buffer, 0, buffer.Length);
                output.Close();
            }
        }

        public async void RemoveConnection(Connection conn)
        {
            Connections.Remove(conn);
        }

        public void HandleConnections(Socket ServerSocket, int Port)
        {
            while (true)
            {
                Socket Client = ServerSocket.Accept();
                Connection conn = new Connection(Client);
                Connections.Add(conn);
                Console.WriteLine("Connected new Client to Port: "+Port+": " + Client.RemoteEndPoint);
            }
        }
    }
}