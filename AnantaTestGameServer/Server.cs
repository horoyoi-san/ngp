
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer
{
    public class Server
    {


        public static Server Instance;
        public List<Connection> Connections = new List<Connection>();
        public void Start()
        {
            Instance = this;
            Logger.Initialize(false);
            {
                Assembly assembly = Assembly.GetExecutingAssembly();
                Type[] types = assembly.GetTypes();

                foreach (var type in types)
                {
                    NotifyManager.AddReqGroupHandler(type);
                }

                NotifyManager.Init();
                
            }
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
            Console.WriteLine($"Server in ascolto sulle porte 5200, 5201, 5202...");
            LoginListDispatch.Start();


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
