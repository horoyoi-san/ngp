using System;
using System.Collections.Generic;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    public class AskNewRoomArg : SerializedClass
    {
        public uint roomtype;
        public AskNewRoomArg() { onlyFields = true; }
    }

    public class AskInviteFriendToRoomArg : SerializedClass
    {
        public ulong friendpid;
        public AskInviteFriendToRoomArg() { onlyFields = true; }
    }

    public class AskReplyToFriendRoomInviteArg : SerializedClass
    {
        public ulong inviterpid;
        public bool accept;
        public AskReplyToFriendRoomInviteArg() { onlyFields = true; }
    }

    public class AskKickFriendInRoomArg : SerializedClass
    {
        public ulong friendpid;
        public AskKickFriendInRoomArg() { onlyFields = true; }
    }

    public class AskLeaveRoomArg : SerializedClass
    {
        public AskLeaveRoomArg() { onlyFields = true; }
    }

    public class AskChangeRoomSettingArg : SerializedClass
    {
        public uint settingtype;
        public uint value;
        public AskChangeRoomSettingArg() { onlyFields = true; }
    }

    public class AskChangeTeamLeaderArg : SerializedClass
    {
        public ulong targetpid;
        public AskChangeTeamLeaderArg() { onlyFields = true; }
    }

    public class AskChangeTeamLeaderApplyArg : SerializedClass
    {
        public AskChangeTeamLeaderApplyArg() { onlyFields = true; }
    }

    public class AskApplyToTeamArg : SerializedClass
    {
        public ulong teamid;
        public AskApplyToTeamArg() { onlyFields = true; }
    }

    public class AskResponseTeamInviteArg : SerializedClass
    {
        public ulong inviterpid;
        public bool accept;
        public AskResponseTeamInviteArg() { onlyFields = true; }
    }

    public class AskQueryTeamInfoByPidArg : SerializedClass
    {
        public ulong targetpid;
        public AskQueryTeamInfoByPidArg() { onlyFields = true; }
    }

    public class AskSetTeamSettingArg : SerializedClass
    {
        public uint settingtype;
        public string value;
        public AskSetTeamSettingArg() { onlyFields = true; }
    }

    public class AskSetPersonalTeamSettingArg : SerializedClass
    {
        public uint settingtype;
        public string value;
        public AskSetPersonalTeamSettingArg() { onlyFields = true; }
    }

    public class AskJoinFriendModeRoomArg : SerializedClass
    {
        public ulong hostpid;
        public AskJoinFriendModeRoomArg() { onlyFields = true; }
    }

    public static class TeamRoomHandlers
    {
        private static void SendEmptySuccessReturn(Connection conn, UxRpcMessage msg, MethodId methodId)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Return,
                RpcInvokeId = msg.RpcInvokeId,
                RpcRetcode = 0,
                RpcMethodId = (int)methodId,
            };
            conn.SendPacket(rsp);
        }

        [Handler(MethodId.AskNewRoom)]
        public static void AskNewRoomHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskNewRoomArg>();
            Console.WriteLine($"[Team] AskNewRoom type={args.roomtype}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskNewRoom);
        }

        [Handler(MethodId.AskInviteFriendToRoom)]
        public static void AskInviteFriendToRoomHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskInviteFriendToRoomArg>();
            Console.WriteLine($"[Team] AskInviteFriendToRoom friend={args.friendpid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskInviteFriendToRoom);
        }

        [Handler(MethodId.AskReplyToFriendRoomInvite)]
        public static void AskReplyToFriendRoomInviteHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskReplyToFriendRoomInviteArg>();
            Console.WriteLine($"[Team] AskReplyToFriendRoomInvite inviter={args.inviterpid} accept={args.accept}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskReplyToFriendRoomInvite);
        }

        [Handler(MethodId.AskKickFriendInRoom)]
        public static void AskKickFriendInRoomHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskKickFriendInRoomArg>();
            Console.WriteLine($"[Team] AskKickFriendInRoom friend={args.friendpid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskKickFriendInRoom);
        }

        [Handler(MethodId.AskLeaveRoom)]
        public static void AskLeaveRoomHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team] AskLeaveRoom");
            SendEmptySuccessReturn(conn, msg, MethodId.AskLeaveRoom);
        }

        [Handler(MethodId.AskChangeRoomSetting)]
        public static void AskChangeRoomSettingHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskChangeRoomSettingArg>();
            Console.WriteLine($"[Team] AskChangeRoomSetting type={args.settingtype} value={args.value}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskChangeRoomSetting);
        }

        [Handler(MethodId.AskChangeTeamLeader)]
        public static void AskChangeTeamLeaderHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskChangeTeamLeaderArg>();
            Console.WriteLine($"[Team] AskChangeTeamLeader target={args.targetpid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskChangeTeamLeader);
        }

        [Handler(MethodId.AskChangeTeamLeaderApply)]
        public static void AskChangeTeamLeaderApplyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine($"[Team] AskChangeTeamLeaderApply");
            SendEmptySuccessReturn(conn, msg, MethodId.AskChangeTeamLeaderApply);
        }

        [Handler(MethodId.AskApplyToTeam)]
        public static void AskApplyToTeamHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskApplyToTeamArg>();
            Console.WriteLine($"[Team] AskApplyToTeam team={args.teamid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskApplyToTeam);
        }

        [Handler(MethodId.AskResponseTeamInvite)]
        public static void AskResponseTeamInviteHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskResponseTeamInviteArg>();
            Console.WriteLine($"[Team] AskResponseTeamInvite inviter={args.inviterpid} accept={args.accept}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskResponseTeamInvite);
        }

        [Handler(MethodId.AskQueryTeamInfoByPid)]
        public static void AskQueryTeamInfoByPidHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskQueryTeamInfoByPidArg>();
            Console.WriteLine($"[Team] AskQueryTeamInfoByPid target={args.targetpid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskQueryTeamInfoByPid);
        }

        [Handler(MethodId.AskSetTeamSetting)]
        public static void AskSetTeamSettingHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskSetTeamSettingArg>();
            Console.WriteLine($"[Team] AskSetTeamSetting type={args.settingtype}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetTeamSetting);
        }

        [Handler(MethodId.AskSetPersonalTeamSetting)]
        public static void AskSetPersonalTeamSettingHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskSetPersonalTeamSettingArg>();
            Console.WriteLine($"[Team] AskSetPersonalTeamSetting type={args.settingtype}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskSetPersonalTeamSetting);
        }

        [Handler(MethodId.AskJoinFriendModeRoom)]
        public static void AskJoinFriendModeRoomHandler(Connection conn, UxRpcMessage msg)
        {
            var args = msg.GetArgs<AskJoinFriendModeRoomArg>();
            Console.WriteLine($"[Team] AskJoinFriendModeRoom host={args.hostpid}");
            SendEmptySuccessReturn(conn, msg, MethodId.AskJoinFriendModeRoom);
        }
    }
}
