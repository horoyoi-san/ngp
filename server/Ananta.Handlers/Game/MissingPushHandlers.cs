using System;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    internal class MissingPushHandlers
    {
        internal static void SendPushChatGroupDismiss(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.PushChatGroupDismiss,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendPushChatGroupInvite(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.PushChatGroupInvite,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendPushChatGroupInviteReject(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.PushChatGroupInviteReject,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendPushChatGroupMemberJoin(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.PushChatGroupMemberJoin,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendPushChatGroupMemberRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.PushChatGroupMemberRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendPushChatGroupNameChanged(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.PushChatGroupNameChanged,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendPushChatHintListToClient(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.PushChatHintListToClient,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendPushChatMessageToClient(Connection conn, ChatMessage message)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.PushChatMessageToClient,
            };
            rsp.SetArgs(MethodId.PushChatMessageToClient, message);
            conn.SendPacket(rsp);
        }

        internal static void SendPushFriendApplication(Connection conn, ulong senderPid, string message)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.PushFriendApplication,
            };
            var args = new ApplyFriendArg()
            {
                targetpid = conn.GetCurrentSpirit()?.Id ?? 0,
                message = message ?? ""
            };
            rsp.SetArgs(MethodId.PushFriendApplication, args);
            conn.SendPacket(rsp);
        }

        internal static void SendPushFriendApplicationReject(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.PushFriendApplicationReject,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendPushJoinNewChatGroup(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.PushJoinNewChatGroup,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendPushMuteEndTime(Connection conn, uint muteEndTime)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.PushMuteEndTime,
            };
            // MuteEndTime is sent as part of ImSimpleData via PushPlayerImSimpleData
            conn.SendPacket(rsp);
        }

        internal static void SendPushPlayerFriendRelation(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.PushPlayerFriendRelation,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendPushPlayerFriendSimpleData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.PushPlayerFriendSimpleData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendPushPlayerImSimpleData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.PushPlayerImSimpleData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendPushPlayerRemoveFriend(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.PushPlayerRemoveFriend,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendPushSoftMuteEndTime(Connection conn, uint softMuteEndTime)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.PushSoftMuteEndTime,
            };
            // SoftMuteEndTime is sent as part of ImSimpleData via PushPlayerImSimpleData
            conn.SendPacket(rsp);
        }

        internal static void SendSyncInMjGame(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncInMjGame,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjAutoEnterTuoGuan(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjAutoEnterTuoGuan,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjChaDaJiao(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjChaDaJiao,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjChaHuaZhu(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjChaHuaZhu,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjChi(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjChi,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjChuPai(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjChuPai,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjDingQue(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjDingQue,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjDingQueBegin(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjDingQueBegin,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjGameInfo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjGameInfo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjGameOver(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjGameOver,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjGameReconnect(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjGameReconnect,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjGang(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjGang,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjGuo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjGuo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjHanGang(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjHanGang,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjHolds(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjHolds,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjHu(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjHu,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjHuanPai(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjHuanPai,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjHuanPaiBegin(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjHuanPaiBegin,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjHuanPaiResult(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjHuanPaiResult,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjLoginResult(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjLoginResult,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjMaoZhuanYu(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjMaoZhuanYu,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjMoPai(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjMoPai,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjOperations(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjOperations,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjPeng(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjPeng,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjPlayerAdd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjPlayerAdd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjPlayerExit(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjPlayerExit,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjPlayerReady(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjPlayerReady,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjRoomOwnerSeatIndex(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjRoomOwnerSeatIndex,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjRoomState(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjRoomState,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjScoreChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjScoreChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjTuiShui(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjTuiShui,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjTurn(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjTurn,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMjYiPaoDuoXiang(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMjYiPaoDuoXiang,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMahjongChat(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMahjongChat,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchGameLeftFailureDieCount(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchGameLeftFailureDieCount,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchGameMemberLeave(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchGameMemberLeave,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchGameMemberPlayGameAgain(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchGameMemberPlayGameAgain,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchGameMembersAllLoaded(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchGameMembersAllLoaded,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchGameSettleData(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchGameSettleData,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchGameStart(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchGameStart,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomDismissed(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomDismissed,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomDutyConfirm(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomDutyConfirm,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomDutySwapApplication(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomDutySwapApplication,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomDutySwapRemoved(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomDutySwapRemoved,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomInvite(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomInvite,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomKicked(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomKicked,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomMatchCancel(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomMatchCancel,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomMatchStart(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomMatchStart,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomMemberChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomMemberChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomMemberChangePrepare(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomMemberChangePrepare,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomMemberConfirmed(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomMemberConfirmed,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomMemberReady(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomMemberReady,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomNotReady(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomNotReady,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomPrepare(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomPrepare,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomReady(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomReady,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncMatchRoomSettingChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncMatchRoomSettingChange,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLinkMemberAdd(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLinkMemberAdd,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLinkMemberOffline(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLinkMemberOffline,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLinkMemberOnline(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLinkMemberOnline,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncLinkMemberRemove(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncLinkMemberRemove,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendSyncSyncRateLevelUp(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.SyncSyncRateLevelUp,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendGuo(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.Guo,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendHu(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.Hu,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendHuanPai(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.HuanPai,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendNextGame(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.NextGame,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendPeng(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.Peng,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendTuoGuan(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.TuoGuan,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendPartyOver(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.PartyOver,
            };
            conn.SendPacket(rsp);
        }

        internal static void SendProgressStateChange(Connection conn)
        {
            UxRpcMessage rsp = new UxRpcMessage()
            {
                Mode = UxRpcPacketMode.Notify,
                RpcInvokeId = 0,
                RpcRetcode = 0,
                RpcMethodId = (int)MethodId.ProgressStateChange,
            };
            conn.SendPacket(rsp);
        }

    }
}

