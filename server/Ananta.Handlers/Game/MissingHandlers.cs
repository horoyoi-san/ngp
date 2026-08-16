using System;
using AnantaTestGameServer.Messages;
using AnantaTestGameServer.Methods;
using AnantaTestGameServer.Methods.Return;
using UX.RPC.Protocol;

namespace AnantaTestGameServer.Packets.Req
{
    internal class MissingHandlers
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

        [Handler(MethodId.Guo)]
        public static void GuoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] Guo called");
            SendEmptySuccessReturn(conn, msg, MethodId.Guo);
        }

        [Handler(MethodId.HasOnlinePlayer)]
        public static void HasOnlinePlayerHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] HasOnlinePlayer called");
            SendEmptySuccessReturn(conn, msg, MethodId.HasOnlinePlayer);
        }

        [Handler(MethodId.Hu)]
        public static void HuHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] Hu called");
            SendEmptySuccessReturn(conn, msg, MethodId.Hu);
        }

        [Handler(MethodId.HuanPai)]
        public static void HuanPaiHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] HuanPai called");
            SendEmptySuccessReturn(conn, msg, MethodId.HuanPai);
        }

        [Handler(MethodId.KickOff)]
        public static void KickOffHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] KickOff called");
            SendEmptySuccessReturn(conn, msg, MethodId.KickOff);
        }

        [Handler(MethodId.KillClientApp)]
        public static void KillClientAppHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] KillClientApp called");
            SendEmptySuccessReturn(conn, msg, MethodId.KillClientApp);
        }

        [Handler(MethodId.KillYouKillMeKillUnityAndCrash)]
        public static void KillYouKillMeKillUnityAndCrashHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] KillYouKillMeKillUnityAndCrash called");
            SendEmptySuccessReturn(conn, msg, MethodId.KillYouKillMeKillUnityAndCrash);
        }

        [Handler(MethodId.MuteChat)]
        public static void MuteChatHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] MuteChat called");
            SendEmptySuccessReturn(conn, msg, MethodId.MuteChat);
        }

        [Handler(MethodId.NextGame)]
        public static void NextGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] NextGame called");
            SendEmptySuccessReturn(conn, msg, MethodId.NextGame);
        }

        [Handler(MethodId.NgpushTest)]
        public static void NgpushTestHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] NgpushTest called");
            SendEmptySuccessReturn(conn, msg, MethodId.NgpushTest);
        }

        [Handler(MethodId.NotifyNewHackerPosts)]
        public static void NotifyNewHackerPostsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] NotifyNewHackerPosts called");
            SendEmptySuccessReturn(conn, msg, MethodId.NotifyNewHackerPosts);
        }

        [Handler(MethodId.NpcInteractAction)]
        public static void NpcInteractActionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] NpcInteractAction called");
            SendEmptySuccessReturn(conn, msg, MethodId.NpcInteractAction);
        }

        [Handler(MethodId.PartyOver)]
        public static void PartyOverHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] PartyOver called");
            SendEmptySuccessReturn(conn, msg, MethodId.PartyOver);
        }

        [Handler(MethodId.Peng)]
        public static void PengHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] Peng called");
            SendEmptySuccessReturn(conn, msg, MethodId.Peng);
        }

        [Handler(MethodId.ProgressStateChange)]
        public static void ProgressStateChangeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] ProgressStateChange called");
            SendEmptySuccessReturn(conn, msg, MethodId.ProgressStateChange);
        }

        [Handler(MethodId.QueryCbtUrs)]
        public static void QueryCbtUrsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] QueryCbtUrs called");
            SendEmptySuccessReturn(conn, msg, MethodId.QueryCbtUrs);
        }

        [Handler(MethodId.QueryCbtUrsAll)]
        public static void QueryCbtUrsAllHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] QueryCbtUrsAll called");
            SendEmptySuccessReturn(conn, msg, MethodId.QueryCbtUrsAll);
        }

        [Handler(MethodId.QueryClientCommands)]
        public static void QueryClientCommandsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] QueryClientCommands called");
            SendEmptySuccessReturn(conn, msg, MethodId.QueryClientCommands);
        }

        [Handler(MethodId.QueryPersonalZoneHeadExtendInfo)]
        public static void QueryPersonalZoneHeadExtendInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] QueryPersonalZoneHeadExtendInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.QueryPersonalZoneHeadExtendInfo);
        }

        [Handler(MethodId.QueryQuestionnaire)]
        public static void QueryQuestionnaireHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] QueryQuestionnaire called");
            SendEmptySuccessReturn(conn, msg, MethodId.QueryQuestionnaire);
        }

        [Handler(MethodId.QuerySkey)]
        public static void QuerySkeyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] QuerySkey called");
            SendEmptySuccessReturn(conn, msg, MethodId.QuerySkey);
        }

        [Handler(MethodId.QueryWhiteList)]
        public static void QueryWhiteListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] QueryWhiteList called");
            SendEmptySuccessReturn(conn, msg, MethodId.QueryWhiteList);
        }

        [Handler(MethodId.RaceSpeedFinish)]
        public static void RaceSpeedFinishHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] RaceSpeedFinish called");
            SendEmptySuccessReturn(conn, msg, MethodId.RaceSpeedFinish);
        }

        [Handler(MethodId.ReconnectGame)]
        public static void ReconnectGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] ReconnectGame called");
            SendEmptySuccessReturn(conn, msg, MethodId.ReconnectGame);
        }

        [Handler(MethodId.RemoveCurrentTask)]
        public static void RemoveCurrentTaskHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] RemoveCurrentTask called");
            SendEmptySuccessReturn(conn, msg, MethodId.RemoveCurrentTask);
        }

        [Handler(MethodId.RemoveLocation)]
        public static void RemoveLocationHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] RemoveLocation called");
            SendEmptySuccessReturn(conn, msg, MethodId.RemoveLocation);
        }

        [Handler(MethodId.RenamePlayer)]
        public static void RenamePlayerHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] RenamePlayer called");
            SendEmptySuccessReturn(conn, msg, MethodId.RenamePlayer);
        }

        [Handler(MethodId.ResetPlayerHeadInfo)]
        public static void ResetPlayerHeadInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] ResetPlayerHeadInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.ResetPlayerHeadInfo);
        }

        [Handler(MethodId.ResetPlayerSignature)]
        public static void ResetPlayerSignatureHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] ResetPlayerSignature called");
            SendEmptySuccessReturn(conn, msg, MethodId.ResetPlayerSignature);
        }

        [Handler(MethodId.SaveCustomInteractionInfo)]
        public static void SaveCustomInteractionInfoHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SaveCustomInteractionInfo called");
            SendEmptySuccessReturn(conn, msg, MethodId.SaveCustomInteractionInfo);
        }

        [Handler(MethodId.SendCommonNotice)]
        public static void SendCommonNoticeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCommonNotice called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCommonNotice);
        }

        [Handler(MethodId.SendCustomCommonDataClientToGame)]
        public static void SendCustomCommonDataClientToGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomCommonDataClientToGame called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomCommonDataClientToGame);
        }

        [Handler(MethodId.SendCustomCommonDataClientToGame_2)]
        public static void SendCustomCommonDataClientToGame_2Handler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomCommonDataClientToGame_2 called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomCommonDataClientToGame_2);
        }

        [Handler(MethodId.SendCustomCommonDataClientToGame_3)]
        public static void SendCustomCommonDataClientToGame_3Handler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomCommonDataClientToGame_3 called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomCommonDataClientToGame_3);
        }

        [Handler(MethodId.SendCustomCommonDataClientToGate)]
        public static void SendCustomCommonDataClientToGateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomCommonDataClientToGate called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomCommonDataClientToGate);
        }

        [Handler(MethodId.SendCustomCommonDataClientToLogi)]
        public static void SendCustomCommonDataClientToLogiHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomCommonDataClientToLogi called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomCommonDataClientToLogi);
        }

        [Handler(MethodId.SendCustomHotPatchAllToClient)]
        public static void SendCustomHotPatchAllToClientHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomHotPatchAllToClient called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomHotPatchAllToClient);
        }

        [Handler(MethodId.SendCustomHotPatchAvatarToClient)]
        public static void SendCustomHotPatchAvatarToClientHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomHotPatchAvatarToClient called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomHotPatchAvatarToClient);
        }

        [Handler(MethodId.SendCustomHotPatchChatToClient)]
        public static void SendCustomHotPatchChatToClientHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomHotPatchChatToClient called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomHotPatchChatToClient);
        }

        [Handler(MethodId.SendCustomHotPatchClientToAvatar)]
        public static void SendCustomHotPatchClientToAvatarHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomHotPatchClientToAvatar called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomHotPatchClientToAvatar);
        }

        [Handler(MethodId.SendCustomHotPatchClientToGame)]
        public static void SendCustomHotPatchClientToGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomHotPatchClientToGame called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomHotPatchClientToGame);
        }

        [Handler(MethodId.SendCustomHotPatchClientToGameSc)]
        public static void SendCustomHotPatchClientToGameScHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomHotPatchClientToGameSc called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomHotPatchClientToGameSc);
        }

        [Handler(MethodId.SendCustomHotPatchClientToGate)]
        public static void SendCustomHotPatchClientToGateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomHotPatchClientToGate called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomHotPatchClientToGate);
        }

        [Handler(MethodId.SendCustomHotPatchClientToLogin)]
        public static void SendCustomHotPatchClientToLoginHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomHotPatchClientToLogin called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomHotPatchClientToLogin);
        }

        [Handler(MethodId.SendCustomHotPatchClientToMinor)]
        public static void SendCustomHotPatchClientToMinorHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomHotPatchClientToMinor called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomHotPatchClientToMinor);
        }

        [Handler(MethodId.SendCustomHotPatchGameSceneToCli)]
        public static void SendCustomHotPatchGameSceneToCliHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomHotPatchGameSceneToCli called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomHotPatchGameSceneToCli);
        }

        [Handler(MethodId.SendCustomHotPatchGateToClient)]
        public static void SendCustomHotPatchGateToClientHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomHotPatchGateToClient called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomHotPatchGateToClient);
        }

        [Handler(MethodId.SendCustomHotPatchLoginToClient)]
        public static void SendCustomHotPatchLoginToClientHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomHotPatchLoginToClient called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomHotPatchLoginToClient);
        }

        [Handler(MethodId.SendCustomHotPatchMahjongPlayerT)]
        public static void SendCustomHotPatchMahjongPlayerTHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomHotPatchMahjongPlayerT called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomHotPatchMahjongPlayerT);
        }

        [Handler(MethodId.SendCustomHotPatchMahjongToClien)]
        public static void SendCustomHotPatchMahjongToClienHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomHotPatchMahjongToClien called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomHotPatchMahjongToClien);
        }

        [Handler(MethodId.SendCustomHotPatchMasterToClient)]
        public static void SendCustomHotPatchMasterToClientHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomHotPatchMasterToClient called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomHotPatchMasterToClient);
        }

        [Handler(MethodId.SendCustomHotPatchMatchToClient)]
        public static void SendCustomHotPatchMatchToClientHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomHotPatchMatchToClient called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomHotPatchMatchToClient);
        }

        [Handler(MethodId.SendCustomHotPatchMatchToClient_2)]
        public static void SendCustomHotPatchMatchToClient_2Handler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomHotPatchMatchToClient_2 called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomHotPatchMatchToClient_2);
        }

        [Handler(MethodId.SendCustomHotPatchMinorToClient)]
        public static void SendCustomHotPatchMinorToClientHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomHotPatchMinorToClient called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomHotPatchMinorToClient);
        }

        [Handler(MethodId.SendCustomMailGm)]
        public static void SendCustomMailGmHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomMailGm called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomMailGm);
        }

        [Handler(MethodId.SendCustomMailGmToAll)]
        public static void SendCustomMailGmToAllHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendCustomMailGmToAll called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendCustomMailGmToAll);
        }

        [Handler(MethodId.SendMail)]
        public static void SendMailHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendMail called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendMail);
        }

        [Handler(MethodId.SendMobileBindSMS)]
        public static void SendMobileBindSMSHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendMobileBindSMS called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendMobileBindSMS);
        }

        [Handler(MethodId.SendMobileUnbind)]
        public static void SendMobileUnbindHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendMobileUnbind called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendMobileUnbind);
        }

        [Handler(MethodId.SendPartyComment)]
        public static void SendPartyCommentHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendPartyComment called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendPartyComment);
        }

        [Handler(MethodId.SendPlayerMailBatch)]
        public static void SendPlayerMailBatchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendPlayerMailBatch called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendPlayerMailBatch);
        }

        [Handler(MethodId.SendServerTime)]
        public static void SendServerTimeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendServerTime called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendServerTime);
        }

        [Handler(MethodId.SendServerTimeGame)]
        public static void SendServerTimeGameHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SendServerTimeGame called");
            SendEmptySuccessReturn(conn, msg, MethodId.SendServerTimeGame);
        }

        [Handler(MethodId.ServerForceGCCollect)]
        public static void ServerForceGCCollectHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] ServerForceGCCollect called");
            SendEmptySuccessReturn(conn, msg, MethodId.ServerForceGCCollect);
        }

        [Handler(MethodId.SetActivityEnable)]
        public static void SetActivityEnableHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SetActivityEnable called");
            SendEmptySuccessReturn(conn, msg, MethodId.SetActivityEnable);
        }

        [Handler(MethodId.SetChallengeResult)]
        public static void SetChallengeResultHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SetChallengeResult called");
            SendEmptySuccessReturn(conn, msg, MethodId.SetChallengeResult);
        }

        [Handler(MethodId.SetChallengeStartTime)]
        public static void SetChallengeStartTimeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SetChallengeStartTime called");
            SendEmptySuccessReturn(conn, msg, MethodId.SetChallengeStartTime);
        }

        [Handler(MethodId.SetChallengeStatisticalData)]
        public static void SetChallengeStatisticalDataHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SetChallengeStatisticalData called");
            SendEmptySuccessReturn(conn, msg, MethodId.SetChallengeStatisticalData);
        }

        [Handler(MethodId.SetGameServerOpen)]
        public static void SetGameServerOpenHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SetGameServerOpen called");
            SendEmptySuccessReturn(conn, msg, MethodId.SetGameServerOpen);
        }

        [Handler(MethodId.SetNewChallengeStartTime)]
        public static void SetNewChallengeStartTimeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SetNewChallengeStartTime called");
            SendEmptySuccessReturn(conn, msg, MethodId.SetNewChallengeStartTime);
        }

        [Handler(MethodId.SetUseWhiteList)]
        public static void SetUseWhiteListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SetUseWhiteList called");
            SendEmptySuccessReturn(conn, msg, MethodId.SetUseWhiteList);
        }

        [Handler(MethodId.ShowLogInClient)]
        public static void ShowLogInClientHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] ShowLogInClient called");
            SendEmptySuccessReturn(conn, msg, MethodId.ShowLogInClient);
        }

        [Handler(MethodId.ShowMemberLinkMessage)]
        public static void ShowMemberLinkMessageHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] ShowMemberLinkMessage called");
            SendEmptySuccessReturn(conn, msg, MethodId.ShowMemberLinkMessage);
        }

        [Handler(MethodId.ShowReceiveRewardDetail)]
        public static void ShowReceiveRewardDetailHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] ShowReceiveRewardDetail called");
            SendEmptySuccessReturn(conn, msg, MethodId.ShowReceiveRewardDetail);
        }

        [Handler(MethodId.ShowServerMessageIdWithArgs)]
        public static void ShowServerMessageIdWithArgsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] ShowServerMessageIdWithArgs called");
            SendEmptySuccessReturn(conn, msg, MethodId.ShowServerMessageIdWithArgs);
        }

        [Handler(MethodId.ShowTaskFailPanel)]
        public static void ShowTaskFailPanelHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] ShowTaskFailPanel called");
            SendEmptySuccessReturn(conn, msg, MethodId.ShowTaskFailPanel);
        }

        [Handler(MethodId.ShowTeamMessageWithPid)]
        public static void ShowTeamMessageWithPidHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] ShowTeamMessageWithPid called");
            SendEmptySuccessReturn(conn, msg, MethodId.ShowTeamMessageWithPid);
        }

        [Handler(MethodId.SoftMuteChat)]
        public static void SoftMuteChatHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] SoftMuteChat called");
            SendEmptySuccessReturn(conn, msg, MethodId.SoftMuteChat);
        }

        [Handler(MethodId.StartProgress)]
        public static void StartProgressHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] StartProgress called");
            SendEmptySuccessReturn(conn, msg, MethodId.StartProgress);
        }

        [Handler(MethodId.StartProgressTemplateCall)]
        public static void StartProgressTemplateCallHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] StartProgressTemplateCall called");
            SendEmptySuccessReturn(conn, msg, MethodId.StartProgressTemplateCall);
        }

        [Handler(MethodId.StopProgress)]
        public static void StopProgressHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] StopProgress called");
            SendEmptySuccessReturn(conn, msg, MethodId.StopProgress);
        }

        [Handler(MethodId.StopProgressTemplateCall)]
        public static void StopProgressTemplateCallHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] StopProgressTemplateCall called");
            SendEmptySuccessReturn(conn, msg, MethodId.StopProgressTemplateCall);
        }

        [Handler(MethodId.TryInteractOuterStory)]
        public static void TryInteractOuterStoryHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] TryInteractOuterStory called");
            SendEmptySuccessReturn(conn, msg, MethodId.TryInteractOuterStory);
        }

        [Handler(MethodId.TryInteractOuterVoice)]
        public static void TryInteractOuterVoiceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] TryInteractOuterVoice called");
            SendEmptySuccessReturn(conn, msg, MethodId.TryInteractOuterVoice);
        }

        [Handler(MethodId.TryInteractStory)]
        public static void TryInteractStoryHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] TryInteractStory called");
            SendEmptySuccessReturn(conn, msg, MethodId.TryInteractStory);
        }

        [Handler(MethodId.TryInteractVoice)]
        public static void TryInteractVoiceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] TryInteractVoice called");
            SendEmptySuccessReturn(conn, msg, MethodId.TryInteractVoice);
        }

        [Handler(MethodId.TryUnlockNpcVoice)]
        public static void TryUnlockNpcVoiceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] TryUnlockNpcVoice called");
            SendEmptySuccessReturn(conn, msg, MethodId.TryUnlockNpcVoice);
        }

        [Handler(MethodId.TuoGuan)]
        public static void TuoGuanHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] TuoGuan called");
            SendEmptySuccessReturn(conn, msg, MethodId.TuoGuan);
        }

        [Handler(MethodId.UnbanUser)]
        public static void UnbanUserHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] UnbanUser called");
            SendEmptySuccessReturn(conn, msg, MethodId.UnbanUser);
        }

        [Handler(MethodId.UnMuteChat)]
        public static void UnMuteChatHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] UnMuteChat called");
            SendEmptySuccessReturn(conn, msg, MethodId.UnMuteChat);
        }

        [Handler(MethodId.UnSoftMuteChat)]
        public static void UnSoftMuteChatHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] UnSoftMuteChat called");
            SendEmptySuccessReturn(conn, msg, MethodId.UnSoftMuteChat);
        }

        [Handler(MethodId.UpdateMapEntrance)]
        public static void UpdateMapEntranceHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] UpdateMapEntrance called");
            SendEmptySuccessReturn(conn, msg, MethodId.UpdateMapEntrance);
        }

        [Handler(MethodId.UploadCapture)]
        public static void UploadCaptureHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] UploadCapture called");
            SendEmptySuccessReturn(conn, msg, MethodId.UploadCapture);
        }

        [Handler(MethodId.UploadClientCommands)]
        public static void UploadClientCommandsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] UploadClientCommands called");
            SendEmptySuccessReturn(conn, msg, MethodId.UploadClientCommands);
        }

        [Handler(MethodId.UserBanned)]
        public static void UserBannedHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[General] UserBanned called");
            SendEmptySuccessReturn(conn, msg, MethodId.UserBanned);
        }

        // ====================================================================
        // Fase 1: Test/Debug Request Stubs
        // ====================================================================

        [Handler(MethodId.TestBusyApp)]
        public static void TestBusyAppHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Test] TestBusyApp called");
            SendEmptySuccessReturn(conn, msg, MethodId.TestBusyApp);
        }

        [Handler(MethodId.TestCDKeyGiftExchange)]
        public static void TestCDKeyGiftExchangeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Test] TestCDKeyGiftExchange called");
            SendEmptySuccessReturn(conn, msg, MethodId.TestCDKeyGiftExchange);
        }

        [Handler(MethodId.TestCheckCDKeyActivation)]
        public static void TestCheckCDKeyActivationHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Test] TestCheckCDKeyActivation called");
            SendEmptySuccessReturn(conn, msg, MethodId.TestCheckCDKeyActivation);
        }

        [Handler(MethodId.TestInviteCDKeyActivation)]
        public static void TestInviteCDKeyActivationHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Test] TestInviteCDKeyActivation called");
            SendEmptySuccessReturn(conn, msg, MethodId.TestInviteCDKeyActivation);
        }

        [Handler(MethodId.TestInviteCDKeyGiftShip)]
        public static void TestInviteCDKeyGiftShipHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Test] TestInviteCDKeyGiftShip called");
            SendEmptySuccessReturn(conn, msg, MethodId.TestInviteCDKeyGiftShip);
        }

        [Handler(MethodId.TestReCallback)]
        public static void TestReCallbackHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Test] TestReCallback called");
            SendEmptySuccessReturn(conn, msg, MethodId.TestReCallback);
        }

        [Handler(MethodId.TestRequestInviteCDKey)]
        public static void TestRequestInviteCDKeyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Test] TestRequestInviteCDKey called");
            SendEmptySuccessReturn(conn, msg, MethodId.TestRequestInviteCDKey);
        }

        [Handler(MethodId.TestRpcMethods)]
        public static void TestRpcMethodsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Test] TestRpcMethods called");
            SendEmptySuccessReturn(conn, msg, MethodId.TestRpcMethods);
        }

        [Handler(MethodId.TestSyncAiBeginSkillAccumulate)]
        public static void TestSyncAiBeginSkillAccumulateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Test] TestSyncAiBeginSkillAccumulate called");
            SendEmptySuccessReturn(conn, msg, MethodId.TestSyncAiBeginSkillAccumulate);
        }

        // ====================================================================
        // Fase 1: Client/Protocol Request Stubs
        // ====================================================================

        [Handler(MethodId.AddSpirit)]
        public static void AddSpiritHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] AddSpirit called");
            SendEmptySuccessReturn(conn, msg, MethodId.AddSpirit);
        }

        [Handler(MethodId.ArchiveInvestigateGallery)]
        public static void ArchiveInvestigateGalleryHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] ArchiveInvestigateGallery called");
            SendEmptySuccessReturn(conn, msg, MethodId.ArchiveInvestigateGallery);
        }

        [Handler(MethodId.BanUser)]
        public static void BanUserHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] BanUser called");
            SendEmptySuccessReturn(conn, msg, MethodId.BanUser);
        }

        [Handler(MethodId.CancelTuoGuan)]
        public static void CancelTuoGuanHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] CancelTuoGuan called");
            SendEmptySuccessReturn(conn, msg, MethodId.CancelTuoGuan);
        }

        [Handler(MethodId.CaptureClient)]
        public static void CaptureClientHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] CaptureClient called");
            SendEmptySuccessReturn(conn, msg, MethodId.CaptureClient);
        }

        [Handler(MethodId.CastVote)]
        public static void CastVoteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] CastVote called");
            SendEmptySuccessReturn(conn, msg, MethodId.CastVote);
        }

        [Handler(MethodId.CastVotes)]
        public static void CastVotesHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] CastVotes called");
            SendEmptySuccessReturn(conn, msg, MethodId.CastVotes);
        }

        [Handler(MethodId.ChangePersonalTimeSetting)]
        public static void ChangePersonalTimeSettingHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] ChangePersonalTimeSetting called");
            SendEmptySuccessReturn(conn, msg, MethodId.ChangePersonalTimeSetting);
        }

        [Handler(MethodId.ChatToNpc)]
        public static void ChatToNpcHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] ChatToNpc called");
            SendEmptySuccessReturn(conn, msg, MethodId.ChatToNpc);
        }

        [Handler(MethodId.ChatWithNpc)]
        public static void ChatWithNpcHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] ChatWithNpc called");
            SendEmptySuccessReturn(conn, msg, MethodId.ChatWithNpc);
        }

        [Handler(MethodId.CheckUserBanned)]
        public static void CheckUserBannedHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] CheckUserBanned called");
            SendEmptySuccessReturn(conn, msg, MethodId.CheckUserBanned);
        }

        [Handler(MethodId.Chi)]
        public static void ChiHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] Chi called");
            SendEmptySuccessReturn(conn, msg, MethodId.Chi);
        }

        [Handler(MethodId.ChuPai)]
        public static void ChuPaiHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] ChuPai called");
            SendEmptySuccessReturn(conn, msg, MethodId.ChuPai);
        }

        [Handler(MethodId.ClaimCityPediaLevelReward)]
        public static void ClaimCityPediaLevelRewardHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] ClaimCityPediaLevelReward called");
            SendEmptySuccessReturn(conn, msg, MethodId.ClaimCityPediaLevelReward);
        }

        [Handler(MethodId.ClearClientPatch)]
        public static void ClearClientPatchHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] ClearClientPatch called");
            SendEmptySuccessReturn(conn, msg, MethodId.ClearClientPatch);
        }

        [Handler(MethodId.ClientToGameGmQA)]
        public static void ClientToGameGmQAHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] ClientToGameGmQA called");
            SendEmptySuccessReturn(conn, msg, MethodId.ClientToGameGmQA);
        }

        [Handler(MethodId.ClientToMinorGmQA)]
        public static void ClientToMinorGmQAHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] ClientToMinorGmQA called");
            SendEmptySuccessReturn(conn, msg, MethodId.ClientToMinorGmQA);
        }

        [Handler(MethodId.CompleteSubQuest)]
        public static void CompleteSubQuestHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] CompleteSubQuest called");
            SendEmptySuccessReturn(conn, msg, MethodId.CompleteSubQuest);
        }

        [Handler(MethodId.CreateSurrenderVote)]
        public static void CreateSurrenderVoteHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] CreateSurrenderVote called");
            SendEmptySuccessReturn(conn, msg, MethodId.CreateSurrenderVote);
        }

        [Handler(MethodId.AddCbtUrs)]
        public static void AddCbtUrsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] AddCbtUrs called");
            SendEmptySuccessReturn(conn, msg, MethodId.AddCbtUrs);
        }

        [Handler(MethodId.DeleteCbtUrs)]
        public static void DeleteCbtUrsHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] DeleteCbtUrs called");
            SendEmptySuccessReturn(conn, msg, MethodId.DeleteCbtUrs);
        }

        [Handler(MethodId.DeleteGlobalMail)]
        public static void DeleteGlobalMailHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] DeleteGlobalMail called");
            SendEmptySuccessReturn(conn, msg, MethodId.DeleteGlobalMail);
        }

        [Handler(MethodId.AddWhiteList)]
        public static void AddWhiteListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] AddWhiteList called");
            SendEmptySuccessReturn(conn, msg, MethodId.AddWhiteList);
        }

        [Handler(MethodId.DeleteWhiteList)]
        public static void DeleteWhiteListHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] DeleteWhiteList called");
            SendEmptySuccessReturn(conn, msg, MethodId.DeleteWhiteList);
        }

        [Handler(MethodId.DingQue)]
        public static void DingQueHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] DingQue called");
            SendEmptySuccessReturn(conn, msg, MethodId.DingQue);
        }

        [Handler(MethodId.DoLuaString)]
        public static void DoLuaStringHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] DoLuaString called");
            SendEmptySuccessReturn(conn, msg, MethodId.DoLuaString);
        }

        [Handler(MethodId.DonateFactionByCfgId)]
        public static void DonateFactionByCfgIdHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] DonateFactionByCfgId called");
            SendEmptySuccessReturn(conn, msg, MethodId.DonateFactionByCfgId);
        }

        [Handler(MethodId.DonateFactionByMoney)]
        public static void DonateFactionByMoneyHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] DonateFactionByMoney called");
            SendEmptySuccessReturn(conn, msg, MethodId.DonateFactionByMoney);
        }

        [Handler(MethodId.Exit)]
        public static void ExitHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] Exit called");
            SendEmptySuccessReturn(conn, msg, MethodId.Exit);
        }

        [Handler(MethodId.FinishNewChallenge)]
        public static void FinishNewChallengeHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] FinishNewChallenge called");
            SendEmptySuccessReturn(conn, msg, MethodId.FinishNewChallenge);
        }

        [Handler(MethodId.FinishTaskTitleGuideUnlock)]
        public static void FinishTaskTitleGuideUnlockHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] FinishTaskTitleGuideUnlock called");
            SendEmptySuccessReturn(conn, msg, MethodId.FinishTaskTitleGuideUnlock);
        }

        [Handler(MethodId.FollowTeamLeader)]
        public static void FollowTeamLeaderHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] FollowTeamLeader called");
            SendEmptySuccessReturn(conn, msg, MethodId.FollowTeamLeader);
        }

        [Handler(MethodId.ForceCloseRaid)]
        public static void ForceCloseRaidHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] ForceCloseRaid called");
            SendEmptySuccessReturn(conn, msg, MethodId.ForceCloseRaid);
        }

        [Handler(MethodId.ForceStartFriendRoom)]
        public static void ForceStartFriendRoomHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] ForceStartFriendRoom called");
            SendEmptySuccessReturn(conn, msg, MethodId.ForceStartFriendRoom);
        }

        [Handler(MethodId.Gang)]
        public static void GangHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] Gang called");
            SendEmptySuccessReturn(conn, msg, MethodId.Gang);
        }

        [Handler(MethodId.GetAllChatGroupLatestMessage)]
        public static void GetAllChatGroupLatestMessageHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] GetAllChatGroupLatestMessage called");
            SendEmptySuccessReturn(conn, msg, MethodId.GetAllChatGroupLatestMessage);
        }

        [Handler(MethodId.GetCharacterRandomDialog)]
        public static void GetCharacterRandomDialogHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] GetCharacterRandomDialog called");
            SendEmptySuccessReturn(conn, msg, MethodId.GetCharacterRandomDialog);
        }

        [Handler(MethodId.GetFavorNpcRandomDialog)]
        public static void GetFavorNpcRandomDialogHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] GetFavorNpcRandomDialog called");
            SendEmptySuccessReturn(conn, msg, MethodId.GetFavorNpcRandomDialog);
        }

        [Handler(MethodId.GetGmSdkToken)]
        public static void GetGmSdkTokenHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] GetGmSdkToken called");
            SendEmptySuccessReturn(conn, msg, MethodId.GetGmSdkToken);
        }

        [Handler(MethodId.GetPlayerState)]
        public static void GetPlayerStateHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] GetPlayerState called");
            SendEmptySuccessReturn(conn, msg, MethodId.GetPlayerState);
        }

        [Handler(MethodId.GetSVNVersion)]
        public static void GetSVNVersionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] GetSVNVersion called");
            SendEmptySuccessReturn(conn, msg, MethodId.GetSVNVersion);
        }

        [Handler(MethodId.GetTaskCountersPosition)]
        public static void GetTaskCountersPositionHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] GetTaskCountersPosition called");
            SendEmptySuccessReturn(conn, msg, MethodId.GetTaskCountersPosition);
        }

        [Handler(MethodId.GmUnlockFogMap)]
        public static void GmUnlockFogMapHandler(Connection conn, UxRpcMessage msg)
        {
            Console.WriteLine("[Client] GmUnlockFogMap called");
            SendEmptySuccessReturn(conn, msg, MethodId.GmUnlockFogMap);
        }
    }
}
