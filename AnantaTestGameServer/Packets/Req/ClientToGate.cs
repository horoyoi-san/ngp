using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using Newtonsoft.Json;
using System;
using System.Buffers.Text;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.Json;
using System.Text.Unicode;
using System.Threading.Tasks;
using UX.RPC.Protocol;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace AnantaTestGameServer.Packets.Req
{
    public class ClientToGate
    {
        [Handler(MethodId.Login)]
        public static void Login(Connection conn,UxRpcMessage msg)
        {
            RPCMethodArgsLogin args = msg.GetArgs<RPCMethodArgsLogin>();
            Console.WriteLine(args.ToString());
            
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode=UxRpcPacketMode.Return,
                RpcInvokeId=msg.RpcInvokeId,
                RpcMethodId= msg.RpcMethodId,
                Args = new byte[0]{},
                RpcRetcode= 0
            };
            conn.SendPacket(rsp);
            UxRpcMessage notify3 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncServerAvailableState,
                Args = new byte[4] { 0x00, 0x00, 0x00, 0x00 }
            };
            notify3.SetArgs(MethodId.SyncServerAvailableState, new ServerAvailableState()
            {
                state = ServerAvailableState.EnumServerAvailableState.Normal
            });
            conn.SendPacket(notify3);
            /* UxRpcMessage rsp4 = new UxRpcMessage()
             {
                 Mode = UxRpcPacketMode.Notify,
                 RpcInvokeId = msg.RpcInvokeId,
                 RpcRetcode = 0,
                 RpcMethodId = (int)MethodId.SendServerTime,
                 Args = new byte[4] { 0x00, 0x00, 0x00, 0x00 }
             };
             rsp4.SetArgs(MethodId.SendServerTime, new SendServerTime() { });
             conn.SendPacket(rsp4);
             UxRpcMessage rsp3 = new UxRpcMessage()
             {
                 Mode = UxRpcPacketMode.Notify,
                 RpcInvokeId = msg.RpcInvokeId,
                 RpcRetcode = 0,
                 RpcMethodId = (int)MethodId.SyncGameSwitchToClient3,
                 Args = new byte[4] { 0x00, 0x00, 0x00, 0x00 }
             };
             rsp3.SetArgs(MethodId.SyncGameSwitchToClient3, new SyncGameSwitchToClient());
             conn.SendPacket(rsp3);
            */


            UxRpcMessage rsp5 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncPlayerGameServerInfo,
                Args = new byte[4] { 0x00, 0x00, 0x00, 0x00 }
            };
            if (conn.ClientSocket.RemoteEndPoint is IPEndPoint ep)
            {
                string ip = ep.Address.ToString();
                int port = ep.Port;

                Console.WriteLine($"Client IP: {ip}, Port: {port}");
                rsp5.SetArgs(MethodId.SyncPlayerGameServerInfo, new SyncPlayerGameServerInfo() { Token = args.token, ClientListenIp = "127.0.0.1",ClientListenPort= 5202 });
            }

          

            // Init(conn);
            conn.SendPacket(rsp5);

           
            
            
        }
       
        public static void Init(Connection conn)
        {
            EnterSceneInfo info = new()
            {
                PlayerSessionId = 1,
                InstanceId = 1,
                Position = new()
                {
                    Y = 200,

                },
                GridInfo = new()
                {

                },
                LoadingType = new()
                {
                    Members = new() { 7 },
                    Type = LoadingType.Default
                }
            };
            UxRpcMessage rsp2 = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncEnterScene
            };

            rsp2.SetArgs(MethodId.SyncEnterScene, info);

            conn.SendPacket(rsp2);
        }
    }
}
