using System;
using System.Collections.Generic;
using System.IO;
using AnantaServer.Network;

namespace AnantaServer.Services
{
    public class LoginService
    {
        public const int MethodCheckVersion = 34700853;
        public const int MethodCheckAccount = 34339919;
        public const int MethodCheckAccountPassBy = 34163006;
        public const int MethodTryLogin = 34529582;
        public const int MethodRequestCreateRole = 34383517;
        public const int MethodRequestEnterGame = 34566515;
        public const int MethodSyncRoleList = 35167428;

        public List<RpcPacket> HandleCheckVersion(RpcPacket packet)
        {
            Console.WriteLine("[C# LoginService] CheckVersion received");
            return new List<RpcPacket>
            {
                new RpcPacket(PacketModes.Return, MethodCheckVersion, packet.InvokeId, errId: 0)
            };
        }

        public List<RpcPacket> HandleCheckAccount(RpcPacket packet)
        {
            Console.WriteLine("[C# LoginService] CheckAccount received");
            return new List<RpcPacket>
            {
                new RpcPacket(PacketModes.Return, MethodCheckAccount, packet.InvokeId, errId: 0)
            };
        }

        public List<RpcPacket> HandleCheckAccountPassBy(RpcPacket packet)
        {
            Console.WriteLine("[C# LoginService] CheckAccountPassBy received");
            return new List<RpcPacket>
            {
                new RpcPacket(PacketModes.Return, MethodCheckAccountPassBy, packet.InvokeId, errId: 0)
            };
        }

        public List<RpcPacket> HandleTryLogin(RpcPacket packet, ulong pid)
        {
            Console.WriteLine($"[C# LoginService] TryLogin received, pushing SyncRoleList with PID={pid}");

            var responses = new List<RpcPacket>();

            // 1. Return response (errId = 0)
            responses.Add(new RpcPacket(PacketModes.Return, MethodTryLogin, packet.InvokeId, errId: 0));

            // 2. Server Push: SyncRoleList (MethodId: 35167428) -> uint64 PID
            using var ms = new MemoryStream();
            using var bw = new BinaryWriter(ms);
            bw.Write(pid);

            responses.Add(new RpcPacket(PacketModes.Notify, MethodSyncRoleList, payload: ms.ToArray()));
            return responses;
        }

        public List<RpcPacket> HandleRequestCreateRole(RpcPacket packet, ulong pid)
        {
            Console.WriteLine($"[C# LoginService] RequestCreateRole -> assigning PID={pid}");
            using var ms = new MemoryStream();
            using var bw = new BinaryWriter(ms);
            bw.Write(pid);

            return new List<RpcPacket>
            {
                new RpcPacket(PacketModes.Return, MethodRequestCreateRole, packet.InvokeId, errId: 0, ms.ToArray())
            };
        }

        public List<RpcPacket> HandleRequestEnterGame(RpcPacket packet, int aid, ulong pid, string host, int gatePort, string token)
        {
            Console.WriteLine($"[C# LoginService] RequestEnterGame -> gate {host}:{gatePort}");

            using var ms = new MemoryStream();
            using var bw = new BinaryWriter(ms);

            // Auto.Reader[580]:
            // obj.Aid = reader.ReadInt32()
            // obj.Pid = reader.ReadUInt64()
            // obj.Token = Base.ReadComplex(Auto.Reader[1573])
            bw.Write(aid);
            bw.Write(pid);

            // Auto.Reader[1573]
            bw.Write(PacketModes.MarkCommon); // Complex not null
            bw.Write(aid);
            bw.Write(pid);
            bw.WriteUxString(host);
            bw.Write(gatePort);
            bw.WriteUxString(token);
            bw.Write(1); // GateServerId
            bw.WriteUxString("Player");

            return new List<RpcPacket>
            {
                new RpcPacket(PacketModes.Return, MethodRequestEnterGame, packet.InvokeId, errId: 0, ms.ToArray())
            };
        }
    }
}
