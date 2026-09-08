-- Original chunk: @Lua\LuaFiles\LX6\Service\MatchToClientImpl.lua
-- Decompiled from: 02362_MatchToClientImpl.lua_6519b0fad98a.luajit

slot0 = gRpcChecker
local MatchToClientImpl = slot0:CreateRpcImpl()

MatchToClientImpl.SendCustomHotPatchMatchToClient = function(data)
end

MatchToClientImpl.SyncMatchRoomMemberChange = function(room, memberPid)
	gLinkManager:OnSyncRoomPlayerInfo(room, memberPid)
end

MatchToClientImpl.SyncMatchRoomDismissed = function()
	gLinkManager:OnSyncMatchRoomDismissed()
end

MatchToClientImpl.SyncMatchRoomMatchStart = function(room)
	gLinkManager:BeginSearching(room)
end

MatchToClientImpl.SyncMatchRoomMatchCancel = function(room)
	gLinkManager:EndOfSearching()
end

MatchToClientImpl.SyncMatchRoomReady = function(prepareRoom, isPopup)
	gLinkManager:OnBeginOfConfirmStage(prepareRoom, isPopup)
end

MatchToClientImpl.SyncMatchRoomMemberConfirmed = function(prepareRoom, pid, ready)
	if not ready then
		gLinkManager:OnMemberRejectConfirm()
	else
		gLinkManager:OnMemberConfirm(prepareRoom)
	end
end

MatchToClientImpl.SyncMatchRoomPrepare = function(prepareRoom)
	gLinkManager:OnBeginOfReadyStage(prepareRoom)
end

MatchToClientImpl.SyncMatchRoomMemberReady = function(prepareRoom, pid)
	gLinkManager:OnMemberConfirm(prepareRoom)
end

MatchToClientImpl.SyncMatchRoomNotReady = function(room, memberPid)
	gLinkManager:OnMatchReadyCancel(room, memberPid)
end

MatchToClientImpl.SyncMatchRoomMemberChangePrepareInfo = function(room, pid, prepareInfo)
	gLinkManager:SetReadyInfo(pid, prepareInfo)
end

MatchToClientImpl.SyncMatchRoomSettingChange = function(setting)
	gLinkManager:OnRoomSettingChange(setting)
end

MatchToClientImpl.SyncMatchGameStart = function(room, gameStartTime)
	gLinkManager:OnMatchGameStart(room, gameStartTime)
end

MatchToClientImpl.SyncMatchGameMemberLeave = function(room, pid)
	gLinkManager:OnMatchGameMemberLeave(room, pid)
end

MatchToClientImpl.SyncMatchGameMemberPlayGameAgain = function(room, pid)
	gLinkManager:OnPlayGameAgain(pid)
end

MatchToClientImpl.SyncMatchRoomDutySwapApplication = function(swapInfo)
	gLinkManager:OnBeRequestDutySwap(swapInfo)
end

MatchToClientImpl.SyncMatchRoomDutyConfirm = function(swapInfo, accept)
	gLinkManager:OnDutyConfirm(swapInfo, accept)
end

MatchToClientImpl.SyncMatchRoomDutySwapRemoved = function(swapInfo)
	gLinkManager:OnDutySwapRemoved(swapInfo)
end

MatchToClientImpl.SyncExtraStateChange = function(prepareRoomClient)
	gLinkManager:SyncExtraStateChange(prepareRoomClient)
end

MatchToClientImpl.SyncExtraStateMemberConfirm = function(pid, extraStateConfirmInfo)
	gLinkManager:SyncExtraStateMemberConfirm(pid, extraStateConfirmInfo)
end

MatchToClientImpl.SyncExtraStateFailed = function(room)
	gLinkManager:SyncExtraStateFailed(room)
end

MatchToClientImpl.SyncStageChange = function(room)
	gLinkManager:SyncStageChange(room)
end

MatchToClientImpl.SyncStageFailed = function(room)
	gLinkManager:SyncStageFailed(room)
end

MatchToClientImpl.SyncPrepareInfoChange = function(pid, prepareInfo)
	gLinkManager:SetReadyInfo(pid, prepareInfo)
end

MatchToClientImpl.SyncMatchRoomMemberPutInKeys = function(pid, putInKeys)
	gPlanningBoardManager:OnSyncRoomMemberPutInKeys(pid, putInKeys)
end

MatchToClientImpl.SyncStageMemberConfirm = function(pid, confirmInfo)
	gLinkManager:SyncStageMemberConfirm(pid, confirmInfo)
end

MatchToClientImpl.SyncPrepareRoomMemberChange = function(room)
	local inRoom = false

	if room.Members then
		for i, member in ipairs(room.Members) do
			if member.Pid ~= gPlayerManager.infoLogin.bindData.pid then
				inRoom = true

				break
			end
		end
	end

	if inRoom then
		gLinkManager:SyncPrepareRoomMemberChange(room)
	else
		gLinkManager:SyncStageFailed(room)
	end
end

MatchToClientImpl.SyncPrepareRoomMemberLeave = function()
	gLinkManager:SyncStageFailed(nil)
end

MatchToClientImpl.SyncPrepareRoomSettingChange = function(setting)
	gLinkManager:UpdateStageSettings(setting)
end

return MatchToClientImpl
