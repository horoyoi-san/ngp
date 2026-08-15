local MessageConfig = LTConfig.MessageConfig
local gameProfile = LX6.Engine.ProfileManager.gameProfile
local LinkConfig = LTConfig.LinkConfig
local LinkMultiPlayerConfig = LTConfig.LinkMultiPlayerConfig
local VehicleConfig = LTConfig.VehicleConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local LinkPrepareActionConfig = LTConfig.LinkPrepareActionConfig
local LinkDutyConfig = LTConfig.LinkDutyConfig
local LinkMessageType = UX.Game.LinkMessageType
local LinkProgressConfig = LTConfig.LinkProgressConfig
local StaticProps = {
	AGAIN_STATE = {
		AGAIN = 1,
		REPLAY = 3,
		NEXT = 2,
		None = 0
	}
}
C_LinkManager = DefClass("C_LinkManager", C_LinkManager, nil, StaticProps)
local M = C_LinkManager

function M:ctor()
	self.beInviteDic = {}
	self.LinkData = {}
	self.baseTime = 0
	self.LinkMember = {}
	self.LinkMemberState = {}
	self.LinkMemberPosInfo = {}
	self.LinkMemberVehicleInfo = {}
	self.LinkMemberInfo = {}
	self.LinkMemberUnitInfo = {}
	self.LinkMemberIndex = {
		[UX.Game.LinkMode.None] = {},
		[UX.Game.LinkMode.Public] = {},
		[UX.Game.LinkMode.Private] = {},
		[UX.Game.LinkMode.Match] = {}
	}
	self.IsUnlockedLink = false
	self.HavePrivateLink = false
	self.WaitCallbacks = {}
	self.WaitHandle = nil
	self.sendToOther = false
	self.gameStartTime = 0
	self.roomSetting = {
		AllowNonLeaderInvite = false
	}
	self.matchInfo = {}
	self.currentGameCfg = {}

	self:OnMatchInit()

	self.cs = LX6.Manager.LinkManager.Instance
	self.acceptPopupUpMode = {}

	for i = 1, #LinkConfig.ShowPopupMode do
		self.acceptPopupUpMode[LinkConfig.ShowPopupMode[i]] = true
	end

	local preId = 0
	self.multi2Link = {}

	for i = 0, LinkConfig.count - 1 do
		local cfg = LinkConfig.LoadAt(i)
		preId = 0

		for j = 1, #cfg.ChildItems do
			local mulId = cfg.ChildItems[j]
			local ele = {
				next = 0,
				parent = cfg.Id
			}
			self.multi2Link[mulId] = ele

			if preId ~= 0 then
				self.multi2Link[preId].next = mulId
			end

			preId = mulId
		end
	end
end

function M:Log(...)
	print_debug("[C_LinkManager]", ...)
end

function M:OnInit()
	self.LinkMode = gameProfile.LinkMode
	self.progressMgr = gLinkProgressMgr

	gMessageManager:AddMessageListener(gEventConstants.BEFORE_SWITCH_SCENE, self:CreateAction("OnBeforeSwitchScene"))
	gMessageManager:AddMessageListener(gEventConstants.LOADING_PANEL_CLOSED, self:CreateAction("OnLoadingFinish"))
end

function M:OnBeforeSwitchScene(_, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		return
	end

	self:Clear()
	self:EndOfSearching()
	gNewGamePlayProgressMgr:InitData()
end

function M:OnLoadingFinish()
	if not gPlayerManager.infoLogin.bindData.pid then
		return
	end

	if self.LinkMode == UX.Game.LinkMode.Match then
		if self.currentGameCfg and self.currentGameCfg.ShowMemberInfo then
			gPanelManager:CheckShow(gPanelId.ONLINE_INGAME_PLAYER)
		end

		if self.LinkFailureCount ~= -1 then
			gPanelManager:CheckShow(gPanelId.ONLINE_INGAME_MISSION_PANEL)
		end

		if self.matchState ~= nil then
			self:OnMatchEnd(self.matchState)
		end
	end

	if not self.currentLinkGame then
		gPanelManager:Close(gPanelId.S_ONLINE_PLAY_PREPARE_PANEL)
	end

	self:SetMatchRoom(self.matchRoom)
	gNewGamePlayProgressMgr:AfterLoadingPanelClosed()
end

function M:Clear()
	self.beInviteDic = {}
	self.LinkMemberPosInfo = {}
	self.LinkMemberInfo = {}
	self.LinkMemberVehicleInfo = {}

	self:OnMatchInit()
end

function M:OnChangeMemberOnlineState(member, online, mode)
	local pid = member.Pid

	if self.LinkMember[pid] then
		self.LinkMember[pid].OnlineState = online and UX.Game.PlayerState.Online or UX.Game.PlayerState.Offline
	end

	self:AddLinkPlayerInfo(pid, member, mode)
	self:PushToPopup(pid, online and MessageConfig.LinkMemberOnline or MessageConfig.LinkMemberOffline, online and 1 or 0)
	gMessageManager:SendMessage(gEventConstants.LINK_MEMBER_CHANGE, {
		pid = pid
	})
end

function M:OnMemberPosInfoChange(pid, name, pos, facing, raidId)
	self.LinkMemberPosInfo[pid] = {
		X = pos.X,
		Y = pos.Y,
		Z = pos.Z,
		F = facing,
		RaidId = raidId
	}

	if gMapSubSystem_Player then
		gMapSubSystem_Player:FlushData("CoordChange")
	end
end

function M:OnMemberVehicleInfoChange(pid, vehicleEntityId, vehicleTemplateId, seatIndex)
	local ret = {
		entityId = vehicleEntityId,
		templateId = vehicleTemplateId,
		seatIndex = seatIndex
	}
	local old = self.LinkMemberVehicleInfo[pid]
	self.LinkMemberVehicleInfo[pid] = ret

	if not old or old.entityId ~= vehicleEntityId then
		gMessageManager:SendMessage(gEventConstants.LINK_VEHICLE_CHANGE, pid)
	end
end

function M:OnLinkMemberChange(mode, member, isAdd)
	local pid = member.Pid
	self.LinkMemberState[pid] = isAdd and mode or nil

	self:AddLinkPlayerInfo(pid, isAdd and member or nil, mode)
	self:PushToPopup(pid, isAdd and MessageConfig.LinkNewMemberEnter or MessageConfig.LinkMemberExist, isAdd and 1 or 0)
	gMessageManager:SendMessage(gEventConstants.LINK_MEMBER_CHANGE, {
		pid = pid,
		isAdd = isAdd
	})
end

function M:InitLinkMember(member)
	local pidList = {}
	self.LinkMemberInfo = {}

	for i = 1, #member do
		table.insert(pidList, member[i].Pid)
		self:AddLinkPlayerInfo(member[i].Pid, member[i])
	end

	self:RequestMemberInfoByIdList(pidList, function (data)
		for i = 1, #data do
			self.LinkMemberState[data[i].Pid] = self.LinkMode
		end
	end)
end

function M:ShowLinkMsg(pid, msgType)
	local realName = gFriendManager:GetPlayerRealName(pid)

	if msgType == LinkMessageType.MemberDetach then
		gDisplayMessageMgr:ShowMessage(MessageConfig.PlayerMatchDetachStart, nil, nil, realName)
	elseif msgType == LinkMessageType.MemberDetachToOnline then
		gDisplayMessageMgr:ShowMessage(MessageConfig.PlayerMatchDetachEnd, nil, nil, realName)
	end
end

function M:OnGameCfgInit()
	local cfg = LinkMultiPlayerConfig.GetConfig(self.targetPlayId)

	if not cfg then
		print_error("#NoCreateIssue [LinkManager] 不存在的PlayId", self.targetPlayId)

		return false
	end

	self.currentGameCfg = cfg
	self.LinkFailureCount = cfg.FailureDieCount == 0 and -1 or cfg.FailureDieCount

	return true
end

function M:InitCurrentLinkGame(linkGame)
	self:Log("[InitCurrentLinkGame]", linkGame.GameId)

	self.currentLinkGame = linkGame
	self.targetPlayId = linkGame.GameId

	if not self:OnGameCfgInit() then
		return false
	end

	return true
end

function M:WaitMemberInfo(pid, callback)
	if not pid then
		return
	end

	gFriendManager:GetSimplePlayerInfo(pid, function (data)
		self.LinkMember[pid] = data

		if callback then
			callback()
		end
	end)
end

function M:PushToPopup(pid, mid, showType)
	if gLuaDataManager.gameStage ~= LX6.Scene.SwitchSceneManager.GameStage.GameScene or self.currentLinkGame or pid == gPlayerManager.infoLogin.bindData.pid or not self.acceptPopupUpMode[self.LinkMode] then
		return
	end

	local name = gFriendManager:GetPlayerRealName(pid)

	gDisplayMessageMgr:ShowMessage(mid, nil, nil, name)
end

function M:RequestMemberInfoByIdList(ids, callback)
	if table.isNilOrEmpty(ids) then
		if callback then
			callback({})
		end

		return
	end

	gFriendManager:GetSimplePlayerInfoByPidList(ids, function (datas)
		if table.isNilOrEmpty(datas) and callback then
			callback({})
		end

		for i = 1, #datas do
			self.LinkMember[datas[i].Pid] = datas[i]
		end

		if callback then
			callback(datas)
		end
	end, true)
end

function M:Error(content)
	print_error(gString.Format("[联机系统] %s", content))
end

function M:GetPlayerInLink(pid, mode)
	return self.LinkMemberState[pid] == mode
end

function M:AddLinkPlayerInfo(pid, info, mode)
	local linkMode = mode or self.LinkMode

	if linkMode ~= self.LinkMode then
		self.LinkMemberIndex[linkMode][pid] = info and info.Index or nil

		return
	end

	if info == nil then
		self.LinkMemberInfo[pid] = nil
		self.LinkMemberPosInfo[pid] = nil
		self.LinkMemberVehicleInfo[pid] = nil
		self.LinkMemberIndex[linkMode][pid] = nil
		self.LinkMemberUnitInfo[pid] = nil
		self.LinkMemberState[pid] = nil
	else
		self.LinkMemberInfo[pid] = info
		self.LinkMemberIndex[linkMode][pid] = info.Index
		self.LinkMemberState[pid] = linkMode
	end

	gMessageManager:SendMessage(gEventConstants.LINK_MEMBER_INFO_CHANGE, {
		pid = pid,
		index = info and info.Index or 0
	})
	self.cs:AddLinkPlayerInfo(pid, info and info.Index or 0)
end

function M:GetUnitInfo(pid)
	local flag, unitId = gCS.PlayerUnitMgr:TryGetCurrentSpirit(pid, ulong.zero)

	return flag and gCS.SceneDataMgr.GetUnit(unitId) or nil
end

function M:GetVehicleInfo(pid)
	if pid == gPlayerManager.infoLogin.bindData.pid then
		local entityId = gDriveVehiclesManager.cs_manager.CurDriveVehicleUid
		local vehicle = nil

		if ulong.equals(entityId, 0) then
			vehicle = gDriveVehiclesManager.cs_manager:GetVehicle(entityId)
		end

		return {
			entityId = entityId,
			templateId = vehicle and vehicle.typeId or 0,
			seatIndex = gDriveVehiclesManager.cs_manager.CurDriveSeatIndex
		}
	end

	return self.LinkMemberVehicleInfo[pid] and self.LinkMemberVehicleInfo[pid] or {}
end

function M:GetCurrentLinkInfo(callback)
	gClientToGameDelegate:AskLinkInfos().Callback = function (err, data)
		if err == MessageConfig.LinkNotExist then
			print_debug("GetLinkInfo failed, error =", gCS.Error.GetNameById(err))
			callback()

			return
		end

		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		for _, v in ipairs(data) do
			self.LinkData[v.Mode] = true

			for index, e in ipairs(v.Members) do
				self:AddLinkPlayerInfo(e.Pid, {
					Index = e.LinkIndex
				}, v.Mode)
			end
		end

		callback()
	end
end

function M:SwitchLinkMode(mode)
	if mode == self.LinkMode then
		return
	end

	self.LinkMode = mode

	gClientToGameDelegate:AskSwitchLinkMode(mode).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

function M:CreateNewLink(mode)
	if not gLuaDataManager.isNetworkAvailable then
		gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL, nil)

		return
	end

	gClientToGameDelegate:AskNewLink(mode).Callback = function (err)
		if err == MessageConfig.LinkJoin_InCD or err == MessageConfig.TimeOut then
			gDisplayMessageMgr:ShowMessageContent(MessageConfig.GetConfig(err).Content)

			return
		end

		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if mode == UX.Game.LinkMode.Private then
			gLinkManager:ShowInvitePanel(mode)
		else
			gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL, nil)
		end
	end
end

function M:GetFriendLinkInfo(callback)
	self:RequestMemberInfoByIdList(gFriendManager.friendPids, callback)
end

function M:ShowLinkPanel(callback)
	self.LinkData = {}
	self.LinkMemberState = {}
	self.LinkMemberIndex = {
		[UX.Game.LinkMode.None] = {},
		[UX.Game.LinkMode.Public] = {},
		[UX.Game.LinkMode.Private] = {},
		[UX.Game.LinkMode.Match] = {}
	}

	self:GetCurrentLinkInfo(function ()
		if callback then
			callback()
		else
			gPanelManager:CheckShow(gPanelId.S_ONLINE_MAIN_PANEL)
		end
	end)
end

function M:ShowInvitePanel(mode)
	gPanelManager:CheckShow(gPanelId.S_ONLINE_INVITE_PANEL, {
		mode = mode
	})
end

function M:LeaveLinkRoom(mode, callback)
	gMessageManager:SendMessage(gEventConstants.SHOW_WAITING_PANEL)

	gClientToGameDelegate:AskLeaveLink(mode).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if callback then
			callback()
		end
	end
end

function M:LinkKickOut(playerId, callback)
	gClientToGameDelegate:AskKickFriendFromLink(playerId).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if callback then
			callback()
		end
	end
end

function M:LinkReplyInvite(playerId, agree, callback)
	if self.beInviteDic[playerId] == nil then
		if callback then
			callback()
		end

		return
	end

	local mode = self.beInviteDic[playerId].mode
	self.beInviteDic[playerId] = nil

	if callback then
		callback()
	end

	if agree == true then
		gMessageManager:SendMessage(gEventConstants.SHOW_WAITING_PANEL)
	end

	gClientToGameDelegate:AskReplyToFriendLinkInvite(mode, playerId, agree).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

function M:InviteFriendToLink(playerId, mode)
	gClientToGameDelegate:AskInviteFriendToLink(mode, playerId).Callback = function (err)
		if err == MessageConfig.LinkInvite_AlreadyInLink or err == MessageConfig.LinkJoin_InCD then
			gDisplayMessageMgr:ShowMessageContent(MessageConfig.GetConfig(err).Content)

			return
		end

		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gDisplayMessageMgr:ShowMessageContentDebug("邀请好友联机成功")
	end
end

function M:OnBeInviteToLink(playerId, mode)
	self:WaitMemberInfo(playerId, function ()
		local beInviteEle = {
			inConnect = false,
			playerId = playerId,
			mode = mode
		}
		self.beInviteDic[playerId] = beInviteEle

		gPanelManager:CheckShow(gPanelId.S_ONLINE_BE_INVITE_LIST, {
			playerId = playerId
		})
	end)
end

function M:GetInviteList()
	local ret = {}

	for k, v in pairs(self.beInviteDic) do
		local ele = {
			playerId = v.playerId,
			mode = v.mode
		}

		table.insert(ret, ele)
	end

	return ret
end

function M:OnKickOut(pid)
	gDisplayMessageMgr:ShowMessageContentDebug("您已被踢出联机房间")
end

function M:ChangeAccountLinkState(linkUnlocked, hasPrivateLink)
	self.IsUnlockedLink = linkUnlocked
	self.HavePrivateLink = hasPrivateLink

	if not self.IsUnlockedLink and self.LinkMode ~= UX.Game.LinkMode.None then
		self:OnChangeLinkMode(UX.Game.LinkMode.None)
	end

	gMessageManager:SendMessage(gEventConstants.LINK_MODE_UNLOCK_CHAGE)
end

function M:CheckInLink(mode)
	return self.LinkData[mode] ~= nil and self.LinkMode ~= mode
end

function M:CheckInOut(mode)
	return self.LinkData[mode] ~= nil and self.LinkMode == UX.Game.LinkMode.None
end

function M:CheckInSwitch(mode)
	return self.LinkData[mode] ~= nil and self.LinkMode == UX.Game.LinkMode.Public
end

function M:EnterLink(mode)
	if self:CheckInLink(mode) or mode == UX.Game.LinkMode.None then
		gMessageManager:SendMessage(gEventConstants.SHOW_WAITING_PANEL, nil)
		self:SwitchLinkMode(mode)
	else
		if mode ~= UX.Game.LinkMode.Private then
			gMessageManager:SendMessage(gEventConstants.SHOW_WAITING_PANEL, nil)
		end

		self:CreateNewLink(mode)
	end
end

function M:GetMatchMemberPidByIndex(index)
	local table = self.LinkMemberIndex[UX.Game.LinkMode.Match]

	if table ~= nil then
		for k, v in pairs(table) do
			if v == index then
				return k
			end
		end
	end

	return 0
end

function M:GetLinkMemberList(mode)
	local ret = {}

	for k, v in pairs(self.LinkMemberState) do
		if v == mode then
			local index = self.LinkMemberIndex[v][k]

			if index then
				local ele = {
					tIndex = 0,
					index = index,
					mode = mode,
					playerId = k,
					isSelf = k == gPlayerManager.infoLogin.bindData.pid
				}

				table.insert(ret, ele)
			end
		end
	end

	table.sort(ret, function (a, b)
		return a.index < b.index
	end)

	if #ret < self:GetMaxPlayerNum(mode) and self.LinkMode == mode then
		table.insert(ret, {
			tIndex = 1
		})
	end

	return ret
end

local LINK_STATE = {
	IN_LINE = 3,
	[UX.Game.PlayerState.Online] = 0,
	[UX.Game.PlayerState.Detached] = 2,
	[UX.Game.PlayerState.Offline] = 2
}

function M:GetLinkState(state, isSelf, linkMode, nowMode)
	if isSelf then
		return nowMode == UX.Game.LinkMode.Public and 4 or 1
	end

	if state == UX.Game.PlayerState.Online and linkMode and linkMode ~= nowMode then
		return LINK_STATE.IN_LINE
	end

	return LINK_STATE[state]
end

function M:GetCurrentLinkPlayerNumber()
	local num = 0

	for k, v in pairs(self.LinkMemberState) do
		if v == self.LinkMode then
			num = num + 1
		end
	end

	return num
end

function M:GetMaxPlayerNum(mode)
	return mode == UX.Game.LinkMode.Private and LinkConfig.PrivateLinkMaxPlayerNum or LinkConfig.PublicLinkMaxPlayerNum
end

function M:OnChangeLinkMode(mode)
	self.LinkMode = mode
	gameProfile.LinkMode = mode

	if mode ~= UX.Game.LinkMode.Match then
		LX6.Engine.ProfileManager.SaveGameProperty()
	end

	gMessageManager:SendMessage(gEventConstants.LINK_MODE_CHANGE)
end

function M:CheckInLinkMode()
	return self.LinkMode ~= UX.Game.LinkMode.None
end

function M:CheckInMatchMode()
	return self.LinkMode == UX.Game.LinkMode.Match
end

function M:CheckLinkEnable()
	return gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.LinkUnlock) and gGameSwitch.EnableLink
end

function M:CheckCanCreateLink(noRebuild)
	if not noRebuild then
		self.IsUnlockedLink = gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.LinkUnlock)
	end

	return self.IsUnlockedLink and gGameSwitch.EnableLink
end

function M:CheckCanEnterPrivateLink()
	return self.HavePrivateLink and gGameSwitch.EnableLink
end

function M:CheckIsFullTeam()
	if table.isNilOrEmpty(gTeamManager.members) then
		return false, true
	end

	if not self.targetPlayId then
		return false, true
	end

	local cfg = LinkMultiPlayerConfig.GetConfig(self.targetPlayId)

	if not cfg then
		return false, true
	end

	local playerNums = cfg.PlayerNum
	local miniNum = playerNums[1]
	local fullNum = playerNums[#playerNums]

	return miniNum <= #gTeamManager.members, fullNum < #gTeamManager.members
end

local CONTENT_TYPE = {
	CONTENT = 1,
	TITLE = 0,
	NUMBER = 2,
	TARGET = 3
}

function M:OnRefreshLinkContent(content)
	local store = gStoreManager:GetStoreGroup("OnlineCommonContentTemplate"):GetStoreByWidget(content)

	if not store then
		return
	end

	local cfg = LinkMultiPlayerConfig.GetConfig(self.targetPlayId)

	if not cfg then
		return
	end

	local playerNums = cfg.PlayerNum
	local playerNumStr = ""

	if playerNums[1] == playerNums[#playerNums] then
		playerNumStr = playerNums[1]
	else
		playerNumStr = playerNums[1] .. "-" .. playerNums[#playerNums]
	end

	local names = string.split(cfg.Name, "·")
	store.iconId = cfg.IconId

	if not table.isNilOrEmpty(names) then
		store.nameLabel = names[1]
		store.subTitleLabel = names[2] or ""
	end

	store.contentList:SetSimpleList(0)
	store.contentList:AddSimpleLabel(CONTENT_TYPE.TITLE, TextScriptTextConfig.GetConfig(89901264).Text)
	store.contentList:AddSimpleLabel(CONTENT_TYPE.CONTENT, cfg.Description)
	store.contentList:AddSimpleLabel(CONTENT_TYPE.TITLE, TextScriptTextConfig.GetConfig(89901077).Text)
	store.contentList:AddSimpleLabel(CONTENT_TYPE.NUMBER, gString.Format(TextScriptTextConfig.GetConfig(89901075).Text, playerNumStr))
	store.contentList:RefreshList()
end

function M:GetPlayModeName(modeId)
	modeId = modeId or self.targetPlayId
	local cfg = LinkMultiPlayerConfig.GetConfig(modeId)

	if not cfg then
		return ""
	end

	return cfg.Name
end

function M:GetPlayModeRange(modeId)
	local cfg = LinkMultiPlayerConfig.GetConfig(modeId)

	if not cfg then
		return {
			0,
			0
		}
	end

	return cfg.PlayerNum
end

function M:OnMemberRenderItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup("OnlineCommonPlayerTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.pid = data.memberId
	store.isReady = self:CheckPlayerIsReady(data.memberId) and 1 or 0
	store.isWaiting = self.matchMemberWaitSwitch[data.memberId] and 1 or 0
	store.isSelf = data.memberId == gPlayerManager.infoLogin.bindData.pid and 1 or 0
	local hideDuty = self.matchMemberDuty[gPlayerManager.infoLogin.bindData.pid] == self.matchMemberDuty[data.memberId] or self:CheckPlayerIsReady()
	store.isSame = hideDuty and 1 or 0
	store.numberLabel = self:GetMatchNumber(data.memberId)

	if self.currentGameCfg then
		store.useVehicle = self.currentGameCfg.UseVehicle and 1 or 0

		if store.useVehicle == 0 then
			local vehicleConfigId = self:GetVehicleId(data.memberId)
			local vehicleConfigInfo = VehicleConfig.GetConfig(vehicleConfigId)
			store.carIcon = vehicleConfigInfo and vehicleConfigInfo.SBuyVehicleIconId or 0
		end
	end

	if store.exchangeBtn then
		function store.exchangeBtn.luaClick()
			store.isWaiting = 1

			self:AskExchangeDuty(data.memberId)
		end
	end

	return store
end

function M:OnMatchInit()
	self.matchRoom = nil
	self.matchRoomMemberDict = {}
	self.roomAskInviteDict = {}
	self.matchMemberList = {}
	self.matchMemberReady = {}
	self.matchMemberWaitSwitch = {}
	self.matchMemberInfo = {}
	self.matchReadyInfo = {}
	self.currentLinkGame = nil
	self.tryAgainDict = {}
	self.requestDutySwapQue = {}
	self.matchState = nil
	self.watchState = false
	self.currentWatchPid = ulong.zero

	gChatManager:ResetMessageOfChannelInfo(gChatTopChannel.Channels, UX.Game.MessageChannel.Room)
	self:SetMatchRoom(self.matchRoom)
end

function M:AskStartGameInTeam(modeId)
	gClientToGameDelegate:StartGameInTeam(modeId).Callback = function (err, data0)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self:SetMatchRoom(data0)
	end
end

function M:AskMatchBegin(modeId, isSingle, callback)
	self.targetPlayId = modeId

	if isSingle then
		if gTeamManager:IsInTeam() then
			gClientToGameDelegate:StartMatchInTeam(self.targetPlayId).Callback = function (err)
				if err ~= MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)
				end

				if callback then
					callback()
				end
			end
		else
			gClientToGameDelegate:AskStartSingleMatch(self.targetPlayId).Callback = function (err)
				if err ~= MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)
				end

				if callback then
					callback()
				end
			end
		end
	else
		gClientToGameDelegate:AskStartRoomMatch().Callback = function (err)
			if err ~= MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end

			if callback then
				callback()
			end
		end
	end
end

function M:BeginSearching()
	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_PREPARE_PANEL)

	self.baseTime = Time.unscaledTime

	gMessageManager:SendMessage(gEventConstants.LINK_SEARCHING_REFRESH)

	if self.timeHandle then
		self.timeHandle:Stop()

		self.timeHandle = nil
	end

	self.timeHandle = Timer.New(function ()
		if gPanelManager:IsPanelShowing(gPanelId.S_ONLINE_PLAY_ENTRANCE_HALF_PANEL) or gPanelManager:IsPanelShowing(gPanelId.S_ONLINE_ROOM_PANEL) or gPanelManager:IsPanelShowing(gPanelId.S_ONLINE_PLAY_ENTRANCE_PANEL) then
			gMessageManager:SendMessage(gEventConstants.LINK_SEARCHING_REFRESH)
		else
			gPanelManager:CheckShow(gPanelId.S_ONLINE_PLAY_ENTRANCE_HALF_PANEL)
		end
	end, 1, -1):Start()
end

function M:EndOfSearching()
	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_ENTRANCE_HALF_PANEL)

	self.baseTime = 0

	if self.timeHandle then
		self.timeHandle:Stop()

		self.timeHandle = nil

		gMessageManager:SendMessage(gEventConstants.LINK_SEARCHING_STATE_CHANGE)
	end
end

function M:AskMatchCancel(callback)
	if self.baseTime == 0 then
		return
	end

	gClientToGameDelegate:AskStopMatch().Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end

		if callback then
			callback()
		end
	end
end

function M:OnMatchReady(game)
	if not self:InitCurrentLinkGame(game) then
		return
	end

	local ids = self:GetMatchMemberList(game.ConfirmMembers)

	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_ENTRANCE_PANEL)
	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_ENTRANCE_HALF_PANEL)
	gPanelManager:Close(gPanelId.S_ONLINE_ROOM_PANEL)
	self.progressMgr:AddProgress(self.currentGameCfg.ConfirmType, game.ConfirmStartTime, LinkConfig.ConfirmEntryTime)
	self:RequestMemberInfoByIdList(ids, self:CreateAction("RefreshMatchMemberInfo"))
	self:Log("OnMatchReady")
end

function M:AskConfirm(ready)
	gClientToGameDelegate:AskConfirmMatchResult(ready).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			self:OnMemberRejectConfirm()

			return
		end

		if ready == false then
			self:OnMemberRejectConfirm()
		end
	end
end

function M:GetMatchMemberList(readyMember)
	local game = self.currentLinkGame
	local ids = {}
	self.matchMemberReady = {}
	self.matchMemberList = {}
	self.matchMemberDuty = {}
	self.matchMemberWaitSwitch = {}

	for i = 1, #readyMember do
		self.matchMemberReady[readyMember[i]] = true
	end

	for i = 1, #game.Members do
		local ele = {
			memberId = game.Members[i].Pid
		}
		self.LinkMemberIndex[UX.Game.LinkMode.Match][ele.memberId] = i
		self.matchMemberDuty[ele.memberId] = game.Members[i].Duty

		table.insert(self.matchMemberList, ele)
		table.insert(ids, game.Members[i].Pid)
	end

	return ids
end

function M:OnMatchAllConfirm(game)
	if not self:InitCurrentLinkGame(game) then
		return
	end

	self.tryAgainDict = {}
	self.matchState = nil
	self.dutyId2Info = {}

	for i = 1, #self.currentGameCfg.MemberComposition do
		local dutyIndex = self.currentGameCfg.MemberComposition[i].duty
		self.dutyId2Info[i] = self:GetDutyConfigInfo(dutyIndex)
	end

	self:GetMatchMemberList(game.ReadyMembers)
	gChallengeManager:EndOfOnlineChallenge()

	for k, v in pairs(game.PrepareInfos) do
		self.matchReadyInfo[k] = v
	end

	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_READY_PANEL)
	gPanelManager:Close(gPanelId.S_CHALLENGE_RANK_PANEL)

	if self:CheckIsInBattle() then
		return
	end

	if not self.currentGameCfg.SkipPrepare then
		gPanelManager:CheckShow(gPanelId.S_ONLINE_PLAY_PREPARE_PANEL)
	end
end

function M:RefreshMatchMemberInfo(data)
	for i = 1, #data do
		local member = data[i]
		local headIcon, _ = gHunLunManager:GetHeadIconAndName(member.PzHeadInfo.SystemHeadId)
		local ele = {
			headIcon = headIcon,
			name = member.Name
		}
		self.matchMemberInfo[member.Pid] = ele
		self.matchReadyInfo[member.Pid] = self.currentLinkGame.PrepareInfos[member.Pid]
	end

	gMessageManager:SendMessage(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE)
end

function M:GetMemberInfo(memberId)
	return self.matchMemberInfo[memberId] or self.LinkMember[memberId]
end

function M:OnMemberConfirm(room, isReadyStage)
	self:InitCurrentLinkGame(room)

	local readyMember = {}
	local readyList = isReadyStage and room.ReadyMembers or room.ConfirmMembers

	for i = 1, #readyList do
		local memberId = readyList[i]
		readyMember[memberId] = true
	end

	local isChange = false

	for i = 1, #room.Members do
		local memberId = room.Members[i].Pid
		local isReady = readyMember[memberId] or false

		if self.matchMemberReady[memberId] ~= isReady then
			isChange = true
			self.matchMemberReady[memberId] = isReady
		end
	end

	if isChange then
		gMessageManager:SendMessage(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE)
	end
end

function M:OnMemberRejectConfirm()
	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_READY_PANEL)

	if not self.matchRoom then
		gPanelManager:CheckShow(gPanelId.S_ONLINE_PLAY_ENTRANCE_PANEL)
	elseif not gPanelManager:IsPanelShowing(gPanelId.S_ONLINE_ROOM_PANEL) and self.matchRoomMemberDict[gPlayerManager.infoLogin.bindData.pid] then
		gPanelManager:CheckShow(gPanelId.S_ONLINE_ROOM_PANEL)
	end
end

function M:OnSyncLinkMatchRoomPrepare(roomId, room)
	self:InitCurrentLinkGame(room)
end

function M:OnRoomSettingChange(setting)
	self.roomSetting = setting

	gMessageManager:SendMessage(gEventConstants.LINK_ROOM_SETTING_CHANGE)
end

function M:OnChangeSendToOther()
	self.sendToOther = not self.sendToOther

	gMessageManager:SendMessage(gEventConstants.LINK_ROOM_SETTING_CHANGE)
end

function M:AskNewRoom(autoInvite)
	autoInvite = self:CheckCanInviteAll() and autoInvite or false

	gClientToGameDelegate:AskNewRoom(self.targetPlayId, autoInvite).Callback = function (err, room)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if autoInvite then
			for k, v in pairs(self.LinkMemberInfo) do
				self.roomAskInviteDict[k] = gCS.TimeManager.ServerUnixTime
			end
		end

		self:SetMatchRoom(room)
		gPanelManager:CheckShow(gPanelId.S_ONLINE_ROOM_PANEL)
	end
end

function M:AskInviteFriendToRoom(playerId)
	self.roomAskInviteDict[playerId] = gCS.TimeManager.ServerUnixTime

	gClientToGameDelegate:AskInviteFriendToRoom(playerId).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

function M:SetMatchRoom(matchRoom)
	self:Log("SetMatchRoom", matchRoom)
	gPanelManager:Close(gPanelId.S_CHALLENGE_RANK_PANEL)

	self.matchRoom = matchRoom
	self.matchRoomMemberDict = {}

	if self.matchRoom then
		self.targetPlayId = self.matchRoom.GameId

		for i = 1, #self.matchRoom.Members do
			self.matchRoomMemberDict[self.matchRoom.Members[i].Pid] = true
		end
	else
		gPanelManager:Close(gPanelId.S_ONLINE_ROOM_PANEL)
	end

	if not gPanelManager:IsPanelShowing(gPanelId.S_ONLINE_ROOM_PANEL) and self.matchRoomMemberDict[gPlayerManager.infoLogin.bindData.pid] then
		gPanelManager:CheckShow(gPanelId.S_ONLINE_ROOM_PANEL)
	end

	self:EndOfSearching()
end

function M:CheckRoomCanEnterGame()
	if not self.matchRoom then
		return false
	end

	for i = 1, #self.matchRoom.Members do
		if gCS.TimeManager.ServerUnixTime < self.matchRoom.Members[i].MatchForbidDueTime then
			local time = gString.Format("%ds", self.matchRoom.Members[i].MatchForbidDueTime - gCS.TimeManager.ServerUnixTime)

			gDisplayMessageMgr:ShowMessage(MessageConfig.PrepareMemberForceExitGetCD, nil, nil, time)

			return false
		end
	end

	return true
end

function M:CheckIsRoomLeader()
	return self.matchRoom and self.matchRoom.LeaderPid == gPlayerManager.infoLogin.bindData.pid
end

function M:AskKickFriendFromRoom(playerId)
	gClientToGameDelegate:AskKickFriendInRoom(playerId).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

function M:AskLeaveRoom()
	gClientToGameDelegate:AskLeaveRoom().Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

function M:CheckCanInviteAll()
	if table.isNilOrEmpty(self.matchInfo) then
		return true
	end

	return self.matchInfo.LastInviteAllTime + LinkConfig.InviteAllCD < gCS.TimeManager.ServerUnixTime
end

function M:CheckRoomCanEnterAndStart()
	local range = self:GetPlayModeRange(self.targetPlayId)

	return #self.matchRoom.Members < range[2], range[1] <= #self.matchRoom.Members and #self.matchRoom.Members <= range[2]
end

function M:ChangeAllowNonLeaderInvite()
	if not self:CheckIsRoomLeader() then
		return
	end

	self.roomSetting.AllowNonLeaderInvite = not self.roomSetting.AllowNonLeaderInvite

	gClientToGameDelegate:AskChangeRoomSetting(self.roomSetting).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

function M:CheckPlayerIsReady(memberId)
	memberId = memberId or gPlayerManager.infoLogin.bindData.pid

	return self.matchMemberReady[memberId] == true
end

function M:OnMatchReadyCancel(room, memberPid)
	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_PREPARE_PANEL)

	if self.matchRoom then
		self:SetMatchRoom(self.matchRoom)
	end
end

function M:GetVehicleId(memberId)
	local readyInfo = self.matchReadyInfo[memberId]

	if not self.currentGameCfg then
		return 0
	end

	return readyInfo and readyInfo.VehicleId or 0
end

function M:GetMatchNumber(memberId)
	return self.LinkMemberIndex[UX.Game.LinkMode.Match][memberId] or 0
end

function M:GetCharacterId(memberId)
	local readyInfo = self.matchReadyInfo[memberId]

	return readyInfo and readyInfo.SpiritId or 0
end

function M:GetFashionInfo(memberId)
	local readyInfo = self.matchReadyInfo[memberId]

	return readyInfo and readyInfo.Fashion or nil
end

function M:GetPoseId(memberId)
	local readyInfo = self.matchReadyInfo[memberId]

	return readyInfo and readyInfo.PoseId == 0 and 1 or readyInfo.PoseId or 1
end

function M:GetPoseDetail(memberId)
	local poseId = self:GetPoseId(memberId)
	local cfg = LinkPrepareActionConfig.GetConfig(poseId)

	if not cfg then
		return 0, 0, 0
	end

	return cfg.Action.actionid, cfg.Action.groupid, cfg.Action.expressionid
end

function M:GetReadyInfo(memberId)
	return self.matchReadyInfo[memberId]
end

function M:SetReadyInfo(memberId, readyInfo)
	self.matchReadyInfo[memberId] = readyInfo

	gMessageManager:SendMessage(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE)
end

function M:CheckIsBlockReady()
	if not self.currentLinkGame then
		return false
	end

	return #self.currentLinkGame.ReadyMembers == #self.currentLinkGame.Members
end

function M:SetSelfReadyInfo(readyInfo)
	local currentInfo = self.matchReadyInfo[gPlayerManager.infoLogin.bindData.pid] or {}

	for k, v in pairs(readyInfo) do
		currentInfo[k] = v
	end

	self.matchReadyInfo[gPlayerManager.infoLogin.bindData.pid] = currentInfo
end

function M:AskReadyToPlay(isReady)
	gClientToGameDelegate:AskReadyToPlay(isReady and 0 or 1).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

function M:AskChangePrepareInfo(info)
	gClientToGameDelegate:AskChangePrepareSetting(info).Callback = function (err)
		if err ~= MessageConfig.Ok then
			print_warn("AskChangePrepareInfo failed, error =", gCS.Error.GetNameById(err))

			return
		end
	end
end

function M:OnGetMatchInfo(matchInfo)
	self.matchInfo = matchInfo
end

function M:AskReplyDutySwap(requestId, isAgree, callback)
	gClientToGameDelegate:AskConfirmDutySwap(requestId, isAgree).Callback = function (err)
		if err ~= MessageConfig.Ok then
			print_warn("AskConfirmDutySwap failed, error =", gCS.Error.GetNameById(err))

			return
		end

		if callback then
			callback()
		end
	end
end

function M:AskExchangeDuty(pid)
	local selfDuty = self.matchMemberDuty[gPlayerManager.infoLogin.bindData.pid]
	local targetDuty = self.matchMemberDuty[pid]
	self.matchMemberWaitSwitch[pid] = true

	gClientToGameDelegate:AskApplyDutySwap(selfDuty, pid, targetDuty).Callback = function (err)
		if err ~= MessageConfig.Ok then
			print_warn("AskExchangeDuty failed, error =", gCS.Error.GetNameById(err))

			return
		end
	end
end

function M:OnBeRequestDutySwap(swapInfo)
	table.insert(self.requestDutySwapQue, swapInfo)

	if not gPanelManager:IsPanelShowing(gPanelId.ONLINE_EXCHANGE_REQUEST) then
		gPanelManager:CheckShow(gPanelId.ONLINE_EXCHANGE_REQUEST)
	end
end

function M:OnDutyConfirm(swapInfo, accept)
	self.matchMemberWaitSwitch[swapInfo.TargetPid] = false

	if accept then
		self.matchMemberDuty[swapInfo.SourcePid] = swapInfo.TargetDuty
		self.matchMemberDuty[swapInfo.TargetPid] = swapInfo.SourceDuty
	end

	gMessageManager:SendMessage(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE)
end

function M:OnDutySwapRemoved(swapInfo)
	local ret = {}
	local pids = {
		[swapInfo.TargetPid] = true,
		[swapInfo.SourcePid] = true
	}

	for i = 1, #self.requestDutySwapQue do
		local info = self.requestDutySwapQue[i]

		if not pids[info.TargetPid] and not pids[info.SourcePid] then
			ret[#ret + 1] = info
		end
	end

	self.requestDutySwapQue = ret

	if table.isNilOrEmpty(self.requestDutySwapQue) then
		gPanelManager:Close(gPanelId.ONLINE_EXCHANGE_REQUEST)
	end
end

function M:GetRequestDuty()
	if #self.requestDutySwapQue > 0 then
		return table.remove(self.requestDutySwapQue, 1)
	end

	return nil
end

function M:GetDutyConfigInfo(dutyId)
	local cfg = LinkDutyConfig.GetConfig(dutyId)

	if not cfg then
		return {
			icon = 0,
			name = "",
			desc = ""
		}
	end

	local ele = {
		name = cfg.DutyName,
		desc = cfg.DutyDesc,
		icon = cfg.DutyIcon
	}

	return ele
end

function M:GetRequestMemberInfo(pid, dutyId)
	if not self.currentGameCfg then
		return
	end

	local dutyDescInfo = self:GetDutyConfigInfo(dutyId)
	local ret = {
		pid = pid,
		index = self:GetMatchNumber(pid),
		dutyName = dutyDescInfo.name,
		dutyIcon = dutyDescInfo.icon
	}

	return ret
end

function M:GetDutyDescOfSelf()
	if not self.currentGameCfg then
		return
	end

	local selfDuty = self.matchMemberDuty[gPlayerManager.infoLogin.bindData.pid]

	return self:GetDutyConfigInfo(selfDuty).desc
end

function M:GetDutyDesc()
	local ret = {}

	for i = 1, #self.dutyId2Info do
		local ele = {
			title = self.dutyId2Info[i].name,
			desc = self.dutyId2Info[i].desc
		}

		table.insert(ret, ele)
	end

	return {
		title = TextScriptTextConfig.GetConfig(89901163).Text,
		content = ret
	}
end

function M:CheckHasDuty()
	return not table.isNilOrEmpty(self.dutyId2Info)
end

function M:GetDutyInfoByPid(pid)
	if not self.currentGameCfg or table.isNilOrEmpty(self.matchMemberDuty) then
		return
	end

	local dutyId = self.matchMemberDuty[pid]

	if not dutyId then
		return
	end

	return self:GetDutyConfigInfo(dutyId)
end

function M:OnSyncMatchRoomDismissed()
	self:OnMatchInit()
end

function M:OnSyncRoomPlayerInfo(room, pid)
	if not pid then
		return
	end

	local hasSelf = false

	for i = 1, #room.Members do
		if room.Members[i].Pid == gPlayerManager.infoLogin.bindData.pid then
			hasSelf = true

			break
		end
	end

	if not hasSelf then
		self:OnMatchInit()
		gPanelManager:Close(gPanelId.S_ONLINE_ROOM_PANEL)

		return
	end

	self.roomSetting = room.Setting

	self:WaitMemberInfo(pid, function ()
		self:SetMatchRoom(room)
		gMessageManager:SendMessage(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE)
	end)
end

function M:OnBeKickOutFromRoom()
	gDisplayMessageMgr:ShowMessage(MessageConfig.OnLineRoomBeKickOut)
	gPanelManager:Close(gPanelId.S_ONLINE_ROOM_PANEL)
end

function M:OnBeInviteToRoom(pid, gameId, roomId)
	if pid == gPlayerManager.infoLogin.bindData.pid then
		return
	end

	self:Log("OnBeInviteToRoom", pid, gameId, roomId)
	self:WaitMemberInfo(pid, function ()
		local ele = {
			pid = pid,
			gameId = gameId,
			roomId = roomId
		}

		self.progressMgr:AddProgress(LinkProgressConfig.Invite, gCS.TimeManager.ServerUnixTime, LinkConfig.LinkRoomInviteStayTime, ele)
	end)
end

function M:AskReplyToFriendRoomInvite(roomId, friendPid, agree, callback)
	gClientToGameDelegate:AskReplyToFriendRoomInvite(roomId, friendPid, agree).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if agree then
			self.progressMgr:ClearProgress(LinkProgressConfig.Invite)
		else
			self.progressMgr:UpdateProgress(LinkProgressConfig.Invite)
		end

		if callback then
			callback()
		end
	end
end

function M:OpenPlayerDetailInfo(pid)
	gPanelManager:CheckShow(gPanelId.S_ONLINE_PLAYER_DETAILS_PANEL, {
		pid = pid
	})
end

function M:RefreshFriendAndLinkMemberInfo(callback)
	local ids = {}

	for pid, _ in pairs(self.LinkMemberInfo) do
		if pid ~= gPlayerManager.infoLogin.bindData.pid then
			ids[pid] = true
		end
	end

	for i = 1, #gFriendManager.friendPids do
		ids[gFriendManager.friendPids[i]] = true
	end

	self:RequestMemberInfoByIdList(table.keys(ids), function (data)
		if callback then
			callback()
		end
	end)
end

function M:GetLinkMemberInfo()
	local ret = {}

	for pid, info in pairs(self.LinkMemberInfo) do
		if self:CheckMemberCanInvite(pid) then
			local ele = {
				pid = pid
			}

			table.insert(ret, ele)
		end
	end

	return ret
end

function M:GetFriendemberInfo()
	local ret = {}

	for i = 1, #gFriendManager.friendPids do
		local pid = gFriendManager.friendPids[i]

		if self:CheckMemberCanInvite(pid) then
			local ele = {
				pid = pid
			}

			table.insert(ret, ele)
		end
	end

	return ret
end

function M:CheckMemberCanInvite(pid)
	if not self.LinkMember[pid] or pid == gPlayerManager.infoLogin.bindData.pid then
		return false
	end

	local vo = self.LinkMember[pid]

	return not vo.InMatch and not vo.InRoom and vo.OnlineState == UX.Game.PlayerState.Online
end

function M:GetRoomPlayerInfo()
	local ret = {}

	if not self.matchRoom then
		return ret
	end

	for i = 1, #self.matchRoom.Members do
		local pid = self.matchRoom.Members[i].Pid
		local isSelf = pid == gPlayerManager.infoLogin.bindData.pid
		local ele = {
			id = i,
			pid = pid,
			isSelf = isSelf,
			isLeader = self.matchRoom.LeaderPid == pid
		}

		table.insert(ret, ele)
	end

	return ret
end

function M:OnUserInfoUpdate(store, content, info)
	local onlineState = info.OnlineState and info.OnlineState or UX.Game.PlayerState.Offline

	if onlineState == UX.Game.PlayerState.Online then
		store.stateLabel = TextScriptTextConfig.GetConfig(89900180).Text
	else
		store.stateLabel = TextScriptTextConfig.GetConfig(89901086).Text
	end

	store.inviteBtn.interactable = onlineState == UX.Game.PlayerState.Online
	store.favorLabel = math.floor(info.SyncRate)
end

function M:OnPlayGameAgain(room, pid)
	self.tryAgainDict[pid] = true

	self:CheckAgainClose()
	gMessageManager:SendMessage(gEventConstants.LINK_MEMBER_CHANGE, {
		pid = pid
	})
end

function M:CheckAgainClose()
	if table.count(self.tryAgainDict) == table.count(self.LinkMemberInfo) then
		gChallengeManager:ExitFinalRankPanel()
	end
end

function M:AskStartGame()
	gClientToGameDelegate:AskStartGame().Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gChatManager:ResetMessageOfChannelInfo(gChatTopChannel.Channels, UX.Game.MessageChannel.Room)
		self:AskConfirm(true)
	end
end

function M:AskLeaveGame(hasPunish)
	gClientToGameDelegate:AskLeaveGame(hasPunish).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gChallengeManager:EndOfOnlineChallenge()
	end
end

function M:AskPlayGameAgain(state)
	if state == StaticProps.AGAIN_STATE.NEXT then
		gClientToGameDelegate:AskPlayGameNext().Callback = function (err)
			if err ~= MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end
		end

		return
	end

	gClientToGameDelegate:AskPlayGameAgain().Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

function M:OnMatchGameMemberLeave(room, pid)
	if pid == gPlayerManager.infoLogin.bindData.pid then
		self:OnMatchInit()
	else
		self.tryAgainDict[pid] = false

		gDisplayMessageMgr:ShowMessage(MessageConfig.OnlineMatchMemberExit)
		gMessageManager:SendMessage(gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE)
	end
end

function M:CheckAgainState()
	if not self.currentGameCfg then
		return StaticProps.AGAIN_STATE.None, 244
	end

	local linkele = self.multi2Link[self.currentGameCfg.Id]

	if not linkele then
		return StaticProps.AGAIN_STATE.None, 244
	end

	if not self:CheckCanTryAgain() then
		return StaticProps.AGAIN_STATE.None, 244
	end

	if not self.matchState then
		return StaticProps.AGAIN_STATE.REPLAY, 494
	end

	if linkele.next ~= 0 then
		local cfg = LinkMultiPlayerConfig.GetConfig(linkele.next)
		local currentNum = table.count(self.LinkMemberInfo)

		if cfg.PlayerNum[1] <= currentNum and currentNum <= cfg.PlayerNum[2] then
			return StaticProps.AGAIN_STATE.NEXT, 577
		else
			return StaticProps.AGAIN_STATE.None, 244
		end
	end

	return StaticProps.AGAIN_STATE.AGAIN, 244
end

function M:GetBaseAgainLabel(state)
	if state == StaticProps.AGAIN_STATE.REPLAY then
		return TextScriptTextConfig.GetConfig(89901274).Text
	elseif state == StaticProps.AGAIN_STATE.NEXT then
		return TextScriptTextConfig.GetConfig(89901272).Text
	elseif state == StaticProps.AGAIN_STATE.AGAIN then
		return TextScriptTextConfig.GetConfig(89901273).Text
	end

	return ""
end

function M:GetAgainLabel(state)
	local againNum = 0

	for k, v in pairs(self.tryAgainDict) do
		if v then
			againNum = againNum + 1
		end
	end

	local baseAgainNum = againNum .. "/" .. table.count(self.LinkMemberInfo)
	local baseText = TextScriptTextConfig.GetConfig(89901271).Text
	local stateText = self:GetBaseAgainLabel(state)

	return gString.Format(baseText, baseAgainNum, stateText)
end

function M:CheckCanTryAgain()
	if table.isNilOrEmpty(self.tryAgainDict) then
		return true
	end

	for k, v in pairs(self.tryAgainDict) do
		if not v then
			return false
		end
	end

	return true
end

function M:GetLinkIndex(pid)
	return self.LinkMemberIndex[self.LinkMode][pid]
end

function M:TryExit()
	local hasFrontPlayer = gCarRaceManager:CheckHasFrontPlayer()
	local name = self:GetPlayModeName()

	if hasFrontPlayer then
		gDisplayMessageMgr:ShowMessage(MessageConfig.OnlineRoomExitWarnTip, self:CreateActionWithArgs("AskLeaveGame", true))
	else
		gDisplayMessageMgr:ShowMessage(MessageConfig.OnlineRoomExitNormalTip, self:CreateActionWithArgs("AskLeaveGame", false), nil, name)
	end
end

function M:OnMatchGameLeftFailureCountUpdate(count)
	if self.LinkFailureCount == -1 then
		return
	end

	self.LinkFailureCount = count

	if count == -1 then
		self.matchState = false
	else
		self.matchState = nil
	end

	gMessageManager:SendMessage(gEventConstants.LINK_HUD_INFO_CHANGE)
end

function M:OnMatchEnd(isSuccess)
	self.matchState = isSuccess

	if gPanelManager:IsPanelShowing(gPanelId.S_CHALLENGE_RANK_PANEL) then
		gChallengeManager:OpenFinalRankPanel(true)

		return
	end

	gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
		isSuccess = isSuccess,
		callback = function ()
			gChallengeManager:OpenFinalRankPanel(true)
		end
	})
end

function M:AskWatchOnlinePlayer(pid, callback)
	if pid == self.currentWatchPid then
		if callback then
			callback()
		end

		return
	end

	gClientToGameDelegate:AskLinkWatchOther(pid).Callback = function (err)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if callback then
			callback()
		end
	end
end

function M:OnSyncWatchState(state, watchPid)
	local diff = self.watchState == state
	self.watchState = state
	self.currentWatchPid = watchPid
	local gameplayControlStore = gStoreManager:GetStoreGroup("CoreHudGameplayControlStore")

	if self.watchState and watchPid ~= ulong.zero then
		if gameplayControlStore.curType ~= gHUDGameplayType.InGameWatching then
			gPanelManager:Close(gPanelId.S_CHALLENGE_RANK_PANEL)
			gameplayControlStore:StartGameplayByType(gHUDGameplayType.InGameWatching, {
				onlyShowName = true,
				watchPlayer = watchPid
			})
		end

		gMessageManager:SendMessage(gEventConstants.ONLINE_INGAME_WATCH_PLAYER_CHANGE, watchPid)
		gCS.BaseUnitUtils.FocusOnTarget(watchPid)
	end

	if watchPid == ulong.zero and gameplayControlStore.curType == gHUDGameplayType.InGameWatching then
		gameplayControlStore:StopGameplayByType(gHUDGameplayType.InGameWatching)
		self:ExitIngameWatching()
		gCS.BaseUnitUtils.FocusOnTarget(ulong.zero)
	end

	if not diff then
		gMessageManager:SendMessage(gEventConstants.ONLINE_INGAME_WATCH_STATE_CHANGE)
	end
end

function M:OnWatchOnlinePlayer(pid, fromChallenge)
	pid = pid or 0

	self:AskWatchOnlinePlayer(pid)
end

function M:ExitIngameWatching()
	if self.matchState then
		gChallengeManager:OpenFinalRankPanel(true)
	end
end

function M:CheckIsInRace()
	if not self.currentGameCfg then
		return false
	end

	return self.currentGameCfg.MultiType == LinkMultiPlayerConfig.MultiTypeType.Race
end

function M:CheckIsInBattle()
	if not self.currentGameCfg then
		return false
	end

	return self.currentGameCfg.MultiType == LinkMultiPlayerConfig.MultiTypeType.Battle
end

function M:CheckIsInRaid()
	if not self.currentGameCfg then
		return false
	end

	return self.currentGameCfg.MultiType == LinkMultiPlayerConfig.MultiTypeType.Raid
end

function M:TestOnlinePrepareRoom(playId)
	self.targetPlayId = playId

	if not self:OnGameCfgInit() then
		print_error("#NoCreateIssue [LinkManager] 不存在的PlayId", playId)

		return
	end

	self.matchMemberList = {}
	self.currentLinkGame = {
		PrepareStartTime = gCS.TimeManager.ServerUnixTime,
		Members = {}
	}

	for i = 1, self.currentGameCfg.PlayerNum[2] do
		local id = i

		if i == 1 then
			id = gPlayerManager.infoLogin.bindData.pid
		end

		self.matchReadyInfo[id] = {
			SpiritId = 15020967,
			PoseId = 1,
			VehicleId = 81005002
		}

		table.insert(self.currentLinkGame.Members, {
			Duty = 0,
			Pid = id
		})
	end

	self.matchMemberDuty = {}

	self:GetMatchMemberList({})

	self.dutyId2Info = {}

	for i = 1, #self.currentGameCfg.MemberComposition do
		local dutyIndex = self.currentGameCfg.MemberComposition[i].duty
		self.dutyId2Info[i] = self:GetDutyConfigInfo(dutyIndex)
	end

	gPanelManager:CheckShow(gPanelId.S_ONLINE_PLAY_PREPARE_PANEL)
end

gLinkManager = gLinkManager or C_LinkManager.new()
