-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkManager_LegacyStage.lua
-- Decompiled from: 00719_LinkManager_LegacyStage.lua_1be966be4d90.luajit

local LinkStageConfig = LTConfig.LinkStageConfig
local LinkProgressConfig = LTConfig.LinkProgressConfig
local LinkConfig = LTConfig.LinkConfig
local M = C_LinkManager

M.SyncExtraStateChange = function(self, room)
	self.stageRoom = room

	if not self.BeforeStageEnter(self, room) then
		return
	end

	local stageId = room.StageId

	self.Log(self, "ExtraStateChange", stageId)

	if stageId ~= LinkStageConfig.Invest then
		gPlanningBoardManager:OnInitRoomMemberKeyCounts(room.PrepareInfos)
		gPanelManager:CheckShow(gPanelId.ROBBERY_BOARD_SI_BAI_KE_HOTEL_DIVIDEND_PANEL, {
			multiPlayerId = room.GameId,
			memberList = room.Members
		})
	end
end

M.SyncExtraStateFailed = function(self, room)
	gPanelManager:Close(gPanelId.ROBBERY_BOARD_SI_BAI_KE_HOTEL_DIVIDEND_PANEL)
end

M.OnBeginOfReadyStage = function(self, game)
	if not self.BeforeStageEnter(self, game) then
		return
	end

	self:Log("OnBeginOfReadyStage")
	self:EndOfOnlineChallenge()

	self.tryAgainDict = {}
	self.matchState = nil

	gPanelManager:CheckShow(gPanelId.S_ONLINE_PLAY_PREPARE_PANEL)
end

M.OnBeginOfConfirmStage = function(self, game, isPopup, progressData)
	if not self.BeforeStageEnter(self, game) then
		return
	end

	self:Log("OnBeginOfConfirmStage")

	local groupId = isPopup and LinkProgressConfig.halfConfirm or LinkProgressConfig.fullConfirm
	self.confirmProgressId = self.progressMgr:AddProgress(groupId, game.ConfirmStartTime, LinkConfig.ConfirmEntryTime, progressData)
	local ids = self:GetCurrentLinkGame():GetPidList()

	self:RequestMemberInfoByIdList(ids, function ()
		gMessageManager:SendMessage(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE)
	end)
	self:CheckMatchConfirmPause()
end

M.InitCurrentLinkGame = function(self, linkGame)
	if not linkGame then
		return false
	end

	self.Log(self, "[InitCurrentLinkGame]", linkGame.GameId)

	if not linkGame.Members then
		linkGame.Members = {}
	end

	self.UpdateLinkGame(self, linkGame)

	for i = 1, #linkGame.Members do
		local member = linkGame.Members[i]

		if member then
			self.LinkMemberIndex[UX.Game.LinkMode.Match][member.Pid] = i
		end
	end

	if not self.OnGameCfgInit(self) then
		return false
	end

	return true
end
