-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkManager_Stage.lua
-- Decompiled from: 00716_LinkManager_Stage.lua_5b7eae484da8.luajit

local LinkStageConfig = LTConfig.LinkStageConfig
local LinkProgressConfig = LTConfig.LinkProgressConfig
local LinkConfig = LTConfig.LinkConfig
local MessageConfig = LTConfig.MessageConfig
local PrepareRoomState = UX.Game.PrepareRoomState
local M = C_LinkManager

M.InitLinkGame = function(self)
	self.currentNewLinkGame = nil
end

M.UpdateLinkGame = function(self, linkGameData)
	self.currentLinkGame = linkGameData
	self.targetPlayId = linkGameData and linkGameData.GameId or nil

	if not linkGameData then
		self.currentNewLinkGame = nil
	elseif not self.currentNewLinkGame then
		self.currentNewLinkGame = C_LinkGame.new(linkGameData)
	else
		self.currentNewLinkGame:UpdateData(linkGameData)
	end
end

M.GetCurrentLinkGame = function(self)
	return self.currentNewLinkGame
end

M.OnInitStage = function(self)
	self.stageRoom = nil
	self.confirmProgressId = nil
	self.pendingStartConfirm = nil
end

M.SyncExtraStateMemberConfirm = function(self, pid, confirm)
	gMessageManager:SendMessage(gEventConstants.ON_EXTRA_STATE_MEMBER_CONFIRM_CHANGE)
end

M.BeforeStageEnter = function(self, room)
	if not self.InitCurrentLinkGame(self, room) then
		return false
	end

	self.CloseAllStagePanel(self, room)

	return true
end

M.GetConfirmMembers = function(self, room)
	return room.ConfirmMembers or room.StageConfirmMembers
end

M.GetReadyMembers = function(self, room)
	return room.ReadyMembers or room.StageConfirmMembers
end

M.CheckMatchConfirmPause = function(self)
	if not self.confirmProgressId then
		return
	end

	if not self.currentLinkGame then
		return
	end

	local readyMemeber = {}
	local currentConfirmMembers = self:GetConfirmMembers(self.currentLinkGame)
	local allReady = #currentConfirmMembers ~= #self.currentLinkGame.Members

	for i = 1, #currentConfirmMembers do
		readyMemeber[currentConfirmMembers[i]] = true
	end

	for i = 1, #self.currentLinkGame.Members do
		local member = self.currentLinkGame.Members[i]

		if not readyMemeber[member.Pid] then
			allReady = false

			break
		end
	end

	if allReady then
		self.progressMgr:PauseProgress(self.confirmProgressId)
	end
end

M.OnMatchGameStart = function(self, room, startTime)
	if not self.BeforeStageEnter(self, room) then
		return
	end

	self.Log(self, "OnMatchGameStart")

	self.currentGameStartTime = startTime

	if self.currentGameCfg then
		local maxCount = self.currentGameCfg.FailureDieCount

		if maxCount ~= 0 then
			self.LinkFailureCount = -1
		end
	end

	gLoadingManager:PreShowLoading()

	if self:CheckIsInBattle() then
		gBattlePetsMgr:OnMatchGameStart(room, startTime)
	end
end

M.AskStartGame = function(self, modeId)
	if not gLuaDataManager.isNetworkAvailable then
		return
	end

	if modeId then
		self.targetPlayId = modeId
	end

	self.OnGameCfgInit(self)

	if self.CheckIsRoomLeader(self) and self.CheckRoomCanEnterGame(self, true) then
		self:Log("AskStartGame in room", self.targetPlayId)

		slot2 = gClientToGameDelegate

		slot2:AskStartGame().Callback = function (err)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			gChatManager:ResetMessageOfChannelInfo(gChatTopChannel.Channels, UX.Game.MessageChannel.Room)
			gSocialChatManager:ClearChannelMessages(gSocialChatManager.ChatTopChannel.Channels, UX.Game.MessageChannel.Room)
			self:AskConfirmOnGameStarted()
		end

		return
	end

	if gTeamManager:IsInTeam() and gTeamManager:IsTeamLeader() then
		self:Log("AskStartGame in team", self.targetPlayId)

		slot2 = gClientToGameDelegate

		slot2:StartGameInTeam(self.targetPlayId).Callback = function (err, data0)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			self:AskConfirmOnGameStarted()
		end

		return
	end

	self:Log("AskStartGame in single", self.targetPlayId)

	slot2 = gClientToGameDelegate

	slot2:AskStartSingleGame(self.targetPlayId).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

M.AskConfirmOnGameStarted = function(self)
	if self.currentLinkGame and self.currentLinkGame.StageId and self.currentLinkGame.StageId == 0 and (self.currentLinkGame.StageId ~= LinkStageConfig.Prepare or self.currentLinkGame.StageId ~= LinkStageConfig.FullScreenConfirm or self.currentLinkGame.StageId ~= LinkStageConfig.BubbleConfirm) then
		self.AskConfirm(self, true)
	else
		self.pendingStartConfirm = true
	end
end

M.SyncStageChange = function(self, room)
	if not room then
		self.Error(self, "SyncStageChange room is nil")

		return
	end

	self.Log(self, "SyncStageChange", room)

	if not self.BeforeStageEnter(self, room) then
		self.Error(self, "SyncStageChange Error", room)

		return false
	end

	self.stageRoom = room

	self.EndExitLoading(self)

	if room.State ~= PrepareRoomState.Prepare then
		self.OnInitMatchState(self)

		if room.StageId ~= LinkStageConfig.FullScreenConfirm then
			gCS.GuiUtils.CloseAllFrontUIWithoutTag(nil)
			self.OnStageFullScreenConfirm(self, room)
		elseif room.StageId ~= LinkStageConfig.BubbleConfirm then
			gCS.GuiUtils.CloseAllFrontUIWithoutTag(nil)
			self.OnStageBubbleConfirm(self, room)
		elseif room.StageId ~= LinkStageConfig.Invest then
			gCS.GuiUtils.CloseAllFrontUIWithoutTag(nil)
			self.OnStageInvest(self, room)
		elseif room.StageId ~= LinkStageConfig.Prepare then
			gCS.GuiUtils.CloseAllFrontUIWithoutTag({
				gPanelId.S_ONLINE_CUSTOM_PREPARE_ROOM_PANEL
			})
			self.OnStagePrepare(self, room)
		elseif room.StageId ~= LinkStageConfig.Room then
			gCS.GuiUtils.CloseAllFrontUIWithoutTag(nil)
			self.OnStageRoom(self, room)
		end

		self.TryConfirmOnStartStage(self, room)
	end
end

M.TryConfirmOnStartStage = function(self, room)
	if not self.pendingStartConfirm then
		return
	end

	if room.StageId ~= LinkStageConfig.FullScreenConfirm or room.StageId ~= LinkStageConfig.BubbleConfirm or room.StageId ~= LinkStageConfig.Prepare then
		self.pendingStartConfirm = nil

		self.AskConfirm(self, true, room.StageId)
	end
end

M.SyncStageFailed = function(self, room)
	if not room then
		local linkGame = self.GetCurrentLinkGame(self)
		room = linkGame and linkGame.uxData
	end

	self:Log("SyncStageFailed", room)

	if not room or room.State == PrepareRoomState.Game then
		local whiteList = {
			gPanelId.ONLINE_TABLE_PANEL
		}

		gCS.GuiUtils.CloseAllFrontUIWithoutTag(whiteList)
	end

	if room and room.State ~= PrepareRoomState.Prepare then
		gLinkManager.matchRoom = nil
	end

	gLinkProgressMgr:ClearProgress(LTConfig.LinkProgressConfig.fullConfirm)

	self.pendingStartConfirm = nil

	self:UpdateLinkGame(nil)
end

M.OnStageFullScreenConfirm = function(self, room)
	self:Log("SyncStageChange FullScreenConfirm")

	local ids = self:GetMatchMemberList()
	self.confirmProgressId = self.progressMgr:AddProgress(LinkProgressConfig.fullConfirm, room.StageStartTime, self:GetStageLength(room.GameId, room.StageId))

	self:RequestMemberInfoByIdList(ids, function ()
		gMessageManager:SendMessage(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE)
	end)
	self:CheckMatchConfirmPause()
end

M.OnStageBubbleConfirm = function(self, room)
	self:Log("SyncStageChange BubbleConfirm")

	local ids = self:GetMatchMemberList()
	self.confirmProgressId = self.progressMgr:AddProgress(LinkProgressConfig.halfConfirm, room.StageStartTime, self:GetStageLength(room.GameId, room.StageId))

	self:RequestMemberInfoByIdList(ids, function ()
		gMessageManager:SendMessage(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE)
	end)
	self:CheckMatchConfirmPause()
end

M.OnInitMatchState = function(self)
	self.matchState = nil
	self.tryAgainDict = {}
	self.matchMemberLeave = false
	self.watchState = false
end

M.OnStagePrepare = function(self, room)
	self:Log("SyncStageChange Prepare")
	self:EndOfOnlineChallenge()

	self.tryAgainDict = {}
	self.matchState = nil

	gPlanningBoardManager:OnInitRoomMemberPutInKeys(room.PrepareInfos)
	gMessageManager:SendMessage(gEventConstants.ON_LINK_SYNC_STAGE_CHANGE_PREPARE)

	if self.replacePrepareRoom then
		gPanelManager:CheckShow(gPanelId.S_ONLINE_CUSTOM_PREPARE_ROOM_PANEL)
	else
		gPanelManager:CheckShow(gPanelId.S_ONLINE_PLAY_PREPARE_PANEL)
	end
end

M.OnStageInvest = function(self, room)
	self:Log("SyncStageChange Invest")
	gPlanningBoardManager:OnInitRoomMemberKeyCounts(room.PrepareInfos)
	gPanelManager:CheckShow(gPanelId.ROBBERY_BOARD_SI_BAI_KE_HOTEL_DIVIDEND_PANEL, {
		multiPlayerId = room.GameId,
		memberList = room.Members
	})
end

M.OnStageRoom = function(self, room)
	self:Log("SyncStageChange Room")
	gPanelManager:CheckShow(gPanelId.S_ONLINE_CUSTOM_PREPARE_ROOM_PANEL)
end

M.GetStageLength = function(self, gameId, stage)
	local game = LTConfig.LinkMultiPlayerConfig.GetConfig(gameId)

	if not game then
		self.Error(self, "GetStageLength game config not found for GameId:", gameId)

		return -1
	end

	if not game.Stages then
		self.Error(self, "GetStageLength game.Stages is nil for GameId:", gameId)

		return -1
	end

	for i = 1, #game.Stages do
		if game.Stages[i].Stage ~= stage then
			return game.Stages[i].Timeout
		end
	end

	local fallbackStage = nil

	if stage ~= LinkStageConfig.BubbleConfirm then
		fallbackStage = LinkStageConfig.FullScreenConfirm
	elseif stage ~= LinkStageConfig.FullScreenConfirm then
		fallbackStage = LinkStageConfig.BubbleConfirm
	end

	if fallbackStage then
		for i = 1, #game.Stages do
			if game.Stages[i].Stage ~= fallbackStage then
				return game.Stages[i].Timeout
			end
		end
	end

	self.Error(self, "GetStageLength stage not found for GameId:", gameId, "Stage:", stage)

	return -1
end

M.SyncStageMemberConfirm = function(self, pid, confirmInfo)
	if not self.currentLinkGame then
		return
	end

	if confirmInfo.stageId == self.currentLinkGame.StageId then
		self.Log(self, "Expired Confirm Info", confirmInfo)

		return
	end

	if confirmInfo.confirm then
		if not table.contains(self.currentLinkGame.StageConfirmMembers, pid) then
			table.insert(self.currentLinkGame.StageConfirmMembers, pid)
		end
	else
		for i = #self.currentLinkGame.StageConfirmMembers, 1, -1 do
			if self.currentLinkGame.StageConfirmMembers[i] ~= pid then
				table.remove(self.currentLinkGame.StageConfirmMembers, i)
			end
		end
	end

	if self.currentLinkGame.State == PrepareRoomState.Prepare then
		return
	end

	if confirmInfo.stageId ~= LinkStageConfig.FullScreenConfirm or confirmInfo.stageId ~= LinkStageConfig.BubbleConfirm then
		if confirmInfo.confirm then
			self.OnMemberConfirm(self, self.currentLinkGame)
		else
			self.OnMemberRejectConfirm(self)
		end
	elseif confirmInfo.stageId ~= LinkStageConfig.Prepare then
		self.OnMemberConfirm(self, self.currentLinkGame)
	elseif confirmInfo.stageId ~= LinkStageConfig.Invest then
		gLinkManager:SyncExtraStateMemberConfirm(pid, confirmInfo)
	elseif confirmInfo.stageId ~= LinkStageConfig.Room then
		gMessageManager:SendMessage(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE)
	end
end

M.AskStageConfirm = function(self, stageId, confirm, callback)
	if not gLuaDataManager.isNetworkAvailable then
		if callback then
			callback(false)
		end

		return
	end

	if not stageId or stageId ~= 0 then
		self.Error(self, "AskStageConfirm invalid stageId, skip request. confirm=" .. tostring(confirm))

		if callback then
			callback(false)
		end

		return
	end

	slot4 = gClientToGameDelegate

	slot4:AskStageConfirm({
		stageId = stageId,
		confirm = confirm
	}).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback(false)
			end

			return
		end

		if callback then
			callback(true)
		end
	end
end

M.GetReadyInfo = function(self, pid)
	local linkGame = self:GetCurrentLinkGame()

	return linkGame and linkGame:GetReadyInfo(pid)
end

M.SyncPrepareRoomInvite = function(self, inviterPid, gameId, roomId)
	gInviteManager:Show({
		["mc\\xbf~B\\xb7\\xe1T^cnI"] = "D\\x89\\x84\\xb0т\\xca4\\xa4\\xa4\"",
		type = gInviteManager.TYPE.GAMEPLAY,
		businessKey = tostring(roomId),
		pid = inviterPid,
		timestamp = gLuaDataManager.serverTime,
		stayTime = LinkConfig.LinkRoomInviteStayTime,
		textType = gInviteManager.TEXT_TYPE.INVITE,
		text1 = gLinkManager:GetPlayModeName(gameId),
		callback = function (agree)
			gLinkManager:RespondPrepareRoomInvite(roomId, agree)
		end,
		timeoutCallback = function ()
			gLinkManager:RespondPrepareRoomInvite(roomId, false)
		end
	})
end

M.RespondPrepareRoomInvite = function(self, roomId, accept, callback)
	slot4 = gClientToGameDelegate

	slot4:RespondPrepareRoomInvite(roomId, accept).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if callback then
			callback()
		end
	end
end

M.SyncPrepareRoomMemberChange = function(self, stageRoom)
	if not self.GetCurrentLinkGame(self) then
		self.SyncStageChange(self, stageRoom)

		return
	end

	self:InitCurrentLinkGame(stageRoom)

	slot2 = self:GetCurrentLinkGame()
	local ids = slot2:GetPidList()

	self:RequestMemberInfoByIdList(ids, function ()
		gMessageManager:SendMessage(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE)
	end)
end

M.ClearLinkGame = function(self)
	self.currentNewLinkGame = nil
	self.matchRoom = nil
	self.currentLinkGame = nil
end

M.UpdateStageSettings = function(self, settings)
	if self.currentLinkGame then
		self.currentLinkGame.Setting = settings
	end

	if self.currentNewLinkGame then
		self.currentNewLinkGame.uxData.Setting = settings
	end

	gMessageManager:SendMessage(gEventConstants.LINK_ROOM_SETTING_CHANGE)
end
