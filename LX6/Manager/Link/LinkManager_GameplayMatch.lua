-- Original chunk: @Lua\LuaFiles\LX6\Manager\Link\LinkManager_GameplayMatch.lua
-- Decompiled from: 00707_LinkManager_GameplayMatch.lua_9d72e3d595db.luajit

local MessageConfig = LTConfig.MessageConfig
local LinkProgressConfig = LTConfig.LinkProgressConfig
local LinkMultiPlayerConfig = LTConfig.LinkMultiPlayerConfig
local M = C_LinkManager

local GetPartyMiniGameMatchConfigId = function(playId)
	local cfgs = LTConfig.PartyMiniGameConfig

	for i = 0, cfgs.count - 1 do
		local cfg = cfgs.LoadAt(i)

		if cfg.MultiPlayerId ~= playId then
			return cfg.Id, cfg.MultiPlayerId
		end
	end

	local linkCfg = LTConfig.LinkConfig.GetConfig(playId)

	if linkCfg and linkCfg.ChildItems then
		for i = 1, #linkCfg.ChildItems do
			local configId, childPlayId = GetPartyMiniGameMatchConfigId(linkCfg.ChildItems[i])

			if configId then
				return configId, childPlayId
			end
		end
	end
end

local AddPartyMiniGameConfirmedPid = function(list, pid)
	for i = 1, #list do
		if list[i] ~= pid then
			return
		end
	end

	table.insert(list, pid)
end

M.OnMatchInit = function(self)
	self:Log("OnMatchInit")

	self.matchRoom = nil
	self.matchRoomMemberDict = {}
	self.roomAskInviteDict = {}
	self.matchMemberWaitSwitch = {}
	self.currentLinkGame = nil
	self.tryAgainDict = {}
	self.matchMemberLeave = false
	self.requestDutySwapQue = {}
	self.matchState = nil
	self.matchBeginRequesting = false
	self.watchState = false
	self.currentWatchPid = ulong.zero
	self.currentGameStartTime = 0
	self.lodingInfo = {}
	self.ingameAliveCount = nil
	self.ingameTotalCount = nil
	self.taskId = nil

	gChatManager:ResetMessageOfChannelInfo(gChatTopChannel.Channels, UX.Game.MessageChannel.Room)
	gSocialChatManager:ClearChannelMessages(gSocialChatManager.ChatTopChannel.Channels, UX.Game.MessageChannel.Room)
	self:OnInitVote()
	self:OnInitStage()
	self:OnInitSettleData()
	self:SetMatchRoom(self.matchRoom)
	self:EndOfSearching()
end

M.AskMatchBegin = function(self, modeId, isSingle, callback)
	if self.matchBeginRequesting then
		return
	end

	self.matchBeginRequesting = true

	local onMatchResponse = function(err)
		if err == MessageConfig.Ok then
			self.matchBeginRequesting = false

			gDisplayMessageMgr:DisplayServerMessageId(err)
		end

		if callback then
			callback()
		end
	end

	if modeId then
		self.targetPlayId = modeId
	end

	self.OnGameCfgInit(self)

	local partyMiniGameConfigId, partyMiniGamePlayId = GetPartyMiniGameMatchConfigId(self.targetPlayId)

	if partyMiniGameConfigId then
		self.targetPlayId = partyMiniGamePlayId
		self.partyMiniGameMatchConfigId = partyMiniGameConfigId
		gClientToGameDelegate:AskStartPartyMiniGameMatch(partyMiniGameConfigId).Callback = onMatchResponse

		return
	end

	self.partyMiniGameMatchConfigId = nil

	if isSingle then
		if gTeamManager:IsInTeam() then
			gClientToGameDelegate:StartMatchInTeam(self.targetPlayId).Callback = onMatchResponse
		else
			gClientToGameDelegate:AskStartSingleMatch(self.targetPlayId, false, self:IsAllowAI(self.targetPlayId)).Callback = onMatchResponse
		end
	else
		gClientToGameDelegate:AskStartRoomMatch(false, self:IsAllowAI(self.targetPlayId)).Callback = onMatchResponse
	end
end

M.BeginSearching = function(self, room)
	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_PREPARE_PANEL)

	self.baseTime = Time.unscaledTime
	self.matchBeginRequesting = false

	gMessageManager:SendMessage(gEventConstants.LINK_SEARCHING_REFRESH)

	if self.timeHandle then
		self.timeHandle:Stop()

		self.timeHandle = nil
	end

	self.timeHandle = Timer.New(function ()
		local panelIdList = {
			gPanelId.S_ONLINE_PLAY_ENTRANCE_HALF_PANEL,
			gPanelId.S_ONLINE_ROOM_PANEL,
			gPanelId.S_ONLINE_PLAY_ENTRANCE_PANEL
		}

		for _, panelId in ipairs(panelIdList) do
			if gPanelManager:IsPanelShowing(panelId) then
				gMessageManager:SendMessage(gEventConstants.LINK_SEARCHING_REFRESH)

				return
			end
		end

		gPanelManager:CheckShow(gPanelId.S_ONLINE_PLAY_ENTRANCE_HALF_PANEL, {
			gameId = room and room.GameId
		})
	end, 1, -1):Start()
end

M.EndOfSearching = function(self)
	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_ENTRANCE_HALF_PANEL)

	self.baseTime = 0
	self.matchBeginRequesting = false

	if self.timeHandle then
		self.timeHandle:Stop()

		self.timeHandle = nil

		gMessageManager:SendMessage(gEventConstants.LINK_SEARCHING_STATE_CHANGE)
	end
end

M.SyncPartyMiniGameMatchContext = function(self, room)
	local gameConfigId = GetPartyMiniGameMatchConfigId(room.GameId)
	self.targetPlayId = room.GameId
	self.partyMiniGameMatchConfigId = gameConfigId

	return gameConfigId
end

M.OnPartyMiniGameMatchRoomMatchStart = function(self, room)
	self.SyncPartyMiniGameMatchContext(self, room)
	self.BeginSearching(self)
end

M.OnPartyMiniGameMatchRoomMemberChange = function(self, room)
	self.SyncPartyMiniGameMatchContext(self, room)
	self.BeginSearching(self)
end

M.OnPartyMiniGameMatchRoomReady = function(self, prepareRoom)
	local gameConfigId = self:SyncPartyMiniGameMatchContext(prepareRoom)
	prepareRoom.ReadyMembers = prepareRoom.ConfirmMembers

	self:EndOfSearching()
	gLinkProgressMgr:ClearProgress(LinkProgressConfig.fullConfirm)
	self:OnBeginOfConfirmStage(prepareRoom, false, {
		[";\\x82\\xf9\\xb2\\x8aᨳ\\xaf\\xdc\\xef7\\xeb\\x9b4\\x9c\\xea"] = true,
		gameConfigId = gameConfigId
	})
end

M.OnPartyMiniGameMatchGameStart = function(self, prepareRoom, gameStartTime)
	self.SyncPartyMiniGameMatchContext(self, prepareRoom)

	prepareRoom.ReadyMembers = prepareRoom.ConfirmMembers

	if not self.InitCurrentLinkGame(self, prepareRoom) then
		return false
	end

	self.currentGameStartTime = gameStartTime

	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_READY_PANEL)
	gPanelManager:Close(gPanelId.ONLINE_HALF_PROGRESS)
end

M.OnPartyMiniGameMatchRoomConfirmed = function(self, roomId, pid)
	local room = self.currentLinkGame

	if not room or room.Id == roomId then
		return
	end

	AddPartyMiniGameConfirmedPid(room.ConfirmMembers, pid)
	AddPartyMiniGameConfirmedPid(room.ReadyMembers, pid)
	self.OnMemberConfirm(self, room)
end

M.AskMatchCancel = function(self, callback)
	if self.baseTime ~= 0 then
		return
	end

	if self.partyMiniGameMatchConfigId then
		slot2 = gClientToGameDelegate

		slot2:AskCancelPartyMiniGameMatch(self.partyMiniGameMatchConfigId).Callback = function (err)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			self:EndOfSearching()
			gMessageManager:SendMessage(gEventConstants.LINK_MATCH_CANCEL_SUCCESS)

			if callback then
				callback()
			end
		end

		return
	end

	slot2 = gClientToGameDelegate

	slot2:AskStopMatch().Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end

		gMessageManager:SendMessage(gEventConstants.LINK_MATCH_CANCEL_SUCCESS)

		if callback then
			callback()
		end
	end
end

M.AskConfirm = function(self, ready, stageId)
	if self.useNewStage then
		if not stageId and self.currentLinkGame and self.currentLinkGame.StageId then
			stageId = self.currentLinkGame.StageId
		end

		self.AskStageConfirm(self, stageId, ready, function (isSuccess)
			if isSuccess and ready ~= false then
				self:OnMemberRejectConfirm()
			end
		end)
	else
		slot3 = gClientToGameDelegate

		slot3:AskConfirmMatchResult(ready).Callback = function (err)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
				self:OnMemberRejectConfirm()

				return
			end

			if ready ~= false then
				self:OnMemberRejectConfirm()
			end
		end
	end
end

M.GetMatchMemberList = function(self)
	local game = self.currentLinkGame
	local ids = {}

	if not game or not game.Members then
		return ids
	end

	for i = 1, #game.Members do
		local member = game.Members[i]

		if member then
			table.insert(ids, member.Pid)
		end
	end

	return ids
end

M.GetEndMemberList = function(self)
	local data = self.matchPlayerSettleDatas
	local ids = {}

	for i = 1, #data do
		local member = data[i]

		if member then
			table.insert(ids, member.Pid)
		end
	end

	return ids
end

M.OnMemberConfirm = function(self, room)
	self:InitCurrentLinkGame(room)
	gMessageManager:SendMessage(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE)
	self:CheckMatchConfirmPause()
end

M.OnMemberRejectConfirm = function(self)
	if self.progressMgr:GetCurrentProgress(LinkProgressConfig.halfConfirm) then
		self.progressMgr:OnProgressCancel(LinkProgressConfig.halfConfirm, 1, true)

		return
	end

	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_READY_PANEL)

	if self:CheckTags(LinkMultiPlayerConfig.TagsType.None) then
		if not self.matchRoom then
			-- Nothing
		elseif not gPanelManager:IsPanelShowing(gPanelId.S_ONLINE_ROOM_PANEL) and self.matchRoomMemberDict[gPlayerManager.infoLogin.bindData.pid] then
			gPanelManager:CheckShow(gPanelId.S_ONLINE_ROOM_PANEL)
		end
	end

	gMessageManager:SendMessage(gEventConstants.ON_LINK_MEMBER_REJECT_CONFIRM)
end

M.OnMatchReadyCancel = function(self, room, memberPid)
	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_PREPARE_PANEL)

	if self.matchRoom then
		self.SetMatchRoom(self, self.matchRoom)
	end

	if self.progressMgr:GetCurrentProgress(LinkProgressConfig.halfConfirm) then
		self.progressMgr:OnProgressCancel(LinkProgressConfig.halfConfirm, 1, true)
	end

	gMessageManager:SendMessage(gEventConstants.ON_LINK_MATCH_READY_CANCEL)
end
