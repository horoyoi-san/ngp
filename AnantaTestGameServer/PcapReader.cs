using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using AnantaTestGameServer.Utils;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UX.RPC.Protocol;
using static AnantaTestGameServer.Connection;
using static AnantaTestGameServer.HandlerAttribute;

namespace AnantaTestGameServer
{
    public class PcapReader
    {
        public void Start(string[] lines)
        {
            foreach (string line in lines)
            {
                string packetData = line.Split(":")[1];
                string SorC = line.Split(':')[0];
                byte[] bytes = Enumerable
    .Range(0, packetData.Length / 2)
    .Select(i => Convert.ToByte(packetData.Substring(i * 2, 2), 16))
    .ToArray();
                ProcessPacket(SorC == "S", bytes);
            }
        }
        private List<byte> Buffer = new List<byte>();
        public RC4 rc4encrypt;
        public RC4 rc4Decrypt;
        public byte[] Rc4Key;
        private void ProcessPacket(bool isServer,byte[] bytes)
        {
            Buffer = bytes.ToList();
            while (Buffer.Count >= 4)
            {
                int length = BitConverter.ToInt32(Buffer.ToArray(), 0);

                if (Buffer.Count < 4 + length)
                    return;

                byte[] packetData = Buffer.GetRange(5, length).ToArray();
                if (rc4Decrypt != null && isServer)
                {
                    packetData = rc4Decrypt.Crypt(packetData);
                }
                if (rc4encrypt != null && !isServer)
                {
                    packetData = rc4encrypt.Crypt(packetData);
                }
                UxMessageType type = (UxMessageType)Buffer.GetRange(4, 1).ToArray()[0];
                Buffer.RemoveRange(0, 5 + length);
                UxMessage packet = UxMessageFactory.Create(type, packetData);
                try
                {

                    HandlePacket(packet);
                }
                catch (Exception e)
                {
                    Console.WriteLine(e.Message);
                    Console.WriteLine(e.StackTrace);
                }

            }
        }
        public void HandlePacket(UxMessage packet)
        {
            Console.WriteLine("[Received] " + packet.ToString());
            if (packet.Type == UxMessageType.S2CHandShake)
            {

                UxS2CHandShakeMessage handshake = (UxS2CHandShakeMessage)packet;

                this.Rc4Key = handshake.Keys;
                rc4Decrypt = new RC4(handshake.Keys);
                rc4encrypt = new RC4(handshake.Keys);

            }
            if (packet.Type == UxMessageType.Raw)
            {

                UxRpcMessage req = (UxRpcMessage)packet;
                if(req.RpcMethodId==(int)MethodId.CheckAccount && req.Mode == UxRpcPacketMode.Return)
                {
                    CheckAccountResult msg = req.GetArgs<CheckAccountResult>();
                   
                    Console.WriteLine($"{msg.ToString()}");
                }
                if (req.RpcMethodId == (int)MethodId.TryLogin && req.Mode == UxRpcPacketMode.Invoke )
                {
                    RPCMethodArgsTryLogin msg = req.GetArgs<RPCMethodArgsTryLogin>();

                    Console.WriteLine($"{msg.ToString()}");
                }

                if (req.RpcMethodId == (int)MethodId.AskNewHotFixPatchLogin && req.Mode == UxRpcPacketMode.Invoke)
                {
                    RPCMethodArgsAskNewHotFixPatchLogin msg = req.GetArgs<RPCMethodArgsAskNewHotFixPatchLogin>();

                    Console.WriteLine($"{msg.ToString()}");
                }
                if (req.RpcMethodId == (int)MethodId.AskNewHotFixPatchLogin && req.Mode == UxRpcPacketMode.Return)
                {
                    NewHotFixPatchData msg = req.GetArgs<NewHotFixPatchData>();

                    Console.WriteLine($"{msg.ToString()}");
                }
                if (req.RpcMethodId == (int)MethodId.RequestPatchesCheckDataFromLogin && req.Mode == UxRpcPacketMode.Invoke)
                {
                    RPCMethodArgsRequestPatchesCheckDataFromLogin msg = req.GetArgs<RPCMethodArgsRequestPatchesCheckDataFromLogin>();

                    Console.WriteLine($"{msg.ToString()}");
                }
                if (req.RpcMethodId == (int)MethodId.CheckVersion && req.Mode == UxRpcPacketMode.Invoke)
                {
                    RPCMethodArgsCheckVersion msg = req.GetArgs<RPCMethodArgsCheckVersion>();

                    Console.WriteLine($"{msg.ToString()}");
                }
            }
            if (packet.Type == UxMessageType.Heartbeat)
            {
                UxHeartbeatMessage req = (UxHeartbeatMessage)packet;
                
            }
        }
    }
}
