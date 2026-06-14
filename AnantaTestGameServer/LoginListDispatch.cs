using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;

namespace AnantaTestGameServer
{
    public class LoginListDispatch
    {
        public static void Start()
        {
            var listener = new TcpListener(IPAddress.Any, 5802);
            listener.Start();

            Console.WriteLine("Listening on port 5802...");

            while (true)
            {
                using var client = listener.AcceptTcpClient();
                using var stream = client.GetStream();

                byte[] response = BuildExactResponse();
                stream.Write(response, 0, response.Length);
            }
        }

        public static byte[] BuildExactResponse()
        {
            // BODY
            string body =
                "127.0.0.1:5201\n" +
                "127.0.0.1:5200\n";
            //body = "112.124.40.4:5801\r\n112.124.40.4:5200";
            byte[] bodyBytes = Encoding.ASCII.GetBytes(body);
            string chunkSize = bodyBytes.Length.ToString("X");

            string response =
                "HTTP/1.1 200 OK\r\n" +
                "Content-Type: text/plain\r\n" +
                "Server: Microsoft-NetCore/2.0\r\n" +
                "Date: Mon, 26 Jan 2026 22:32:02 GMT\r\n" +
                "Transfer-Encoding: chunked\r\n" +
                "\r\n" +
                chunkSize + "\r\n" +
                body +
                "\r\n0\r\n\r\n";

            return Encoding.ASCII.GetBytes(response);
        }
    }
}
