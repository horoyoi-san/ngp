using System;
using System.Collections.Generic;
using System.IO;
using AnantaServer.Network;

namespace AnantaServer.Services
{
    public class GateService
    {
        public const int MethodGateLogin = 52023760;
        public const int MethodGetServerTime = 52951195;
        public const int MethodReportNetworkQuality = 52443839;

        public List<RpcPacket> HandleGateLogin(RpcPacket packet)
        {
            Console.WriteLine("[C# GateService] Gate.Login success");
            return new List<RpcPacket>
            {
                new RpcPacket(PacketModes.Return, MethodGateLogin, packet.InvokeId, errId: 0)
            };
        }

        public List<RpcPacket> HandleGetServerTime(RpcPacket packet)
        {
            double now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds() / 1000.0;
            using var ms = new MemoryStream();
            using var bw = new BinaryWriter(ms);
            bw.Write(now);

            return new List<RpcPacket>
            {
                new RpcPacket(PacketModes.Return, MethodGetServerTime, packet.InvokeId, errId: 0, ms.ToArray())
            };
        }
    }
}
