using AnantaTestGameServer.Methods.Return;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static AnantaTestGameServer.Methods.RPCMethodArgsRequestCreateRoleEx;

namespace AnantaTestGameServer.Methods
{
    public class RPCMethodArgsLogin : SerializedClass
    {
        public ulong pid;
        public string token;
        public bool isReconnect;
        public ClientDeviceInfo deviceInfo;
        public PlayerLoginOption debug;


    }
    public class PlayerLoginOption : SerializedClass
    {

        // Fields
		public LinkMode Mode; // 0x10
        public LoginReasonType Reason; // 0x14
        public uint FastPlayRaidId; // 0x18
        public int JumpToMainEvent; // 0x1C
        public int SceneItemQuality; // 0x20
        public UXVector3 FastPlayPosition; // 0x24
        public LoginFromWhere FromWhere; // 0x30
    }
    public enum LoginFromWhere // TypeDefIndex: 28757
    {
        Normal = 0,
        Reconnect = 1,
        LoginReconnect = 2
    }

    public enum LoginReasonType // TypeDefIndex: 28758
    {
        Normal = 0,
        PingPongTimeout = 1,
        ReconnectAfterBackground = 2,
        NetworkSwitchTo4G = 3,
        NetworkSwitchToWifi = 4,
        NetworkSwitch = 5,
        SocketClosed = 6,
        RealNameVerify = 7,
        GuestBind = 8
    }

    public enum LinkMode // TypeDefIndex: 29138
    {
        None = 0,
        Private = 1,
        Public = 2,
        Match = 3
    }
}
