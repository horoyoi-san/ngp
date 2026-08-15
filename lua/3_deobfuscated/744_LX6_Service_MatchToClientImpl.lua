local MatchToClientImpl = gRpcChecker:CreateRpcImpl()

function MatchToClientImpl.SendCustomHotPatchMatchToClient(data)
	return
end

function MatchToClientImpl.SyncMatchRoomMemberChange(room, memberPid)
	gLinkManager:OnSyncRoomPlayerInfo(room, memberPid)
end

function MatchToClientImpl.SyncMatchRoomDismissed()
	gLinkManager:OnSyncMatchRoomDismissed()
end

function MatchToClientImpl.SyncMatchRoomMatchStart(room)
	gLinkManager:BeginSearching()
end

function MatchToClientImpl.SyncMatchRoomMatchCancel(room)
	gLinkManager:EndOfSearching()
end

function MatchToClientImpl.SyncMatchRoomReady(prepareRoom, isPopup)
	gLinkManager:OnMatchReady(prepareRoom)
end

function MatchToClientImpl.SyncMatchRoomMemberConfirmed(prepareRoom, pid, ready)
	if not ready then
		gLinkManager:OnMemberRejectConfirm()
	else
		gLinkManager:OnMemberConfirm(prepareRoom, false)
	end
end

function MatchToClientImpl.SyncMatchRoomPrepare(prepareRoom)
	gLinkManager:OnMatchAllConfirm(prepareRoom)
end

function MatchToClientImpl.SyncMatchRoomMemberReady(prepareRoom, pid)
	gLinkManager:OnMemberConfirm(prepareRoom, true)
end

function MatchToClientImpl.SyncMatchRoomNotReady(room, memberPid)
	gLinkManager:OnMatchReadyCancel(room, memberPid)
end

function MatchToClientImpl.SyncMatchRoomMemberChangePrepareInfo(room, pid, prepareInfo)
	gLinkManager:SetReadyInfo(pid, prepareInfo)
end

function MatchToClientImpl.SyncMatchRoomSettingChange(setting)
	gLinkManager:OnRoomSettingChange(setting)
end

function MatchToClientImpl.SyncMatchGameStart(room, gameStartTime)
	return
end

function MatchToClientImpl.SyncMatchGameMemberLeave(room, pid)
	gLinkManager:OnMatchGameMemberLeave(room, pid)
end

function MatchToClientImpl.SyncMatchGameMemberPlayGameAgain(room, pid)
	gLinkManager:OnPlayGameAgain(room, pid)
end

function MatchToClientImpl.SyncMatchRoomDutySwapApplication(swapInfo)
	gLinkManager:OnBeRequestDutySwap(swapInfo)
end

function MatchToClientImpl.SyncMatchRoomDutyConfirm(swapInfo, accept)
	gLinkManager:OnDutyConfirm(swapInfo, accept)
end

function MatchToClientImpl.SyncMatchRoomDutySwapRemoved(swapInfo)
	gLinkManager:OnDutySwapRemoved(swapInfo)
end

return MatchToClientImpl
