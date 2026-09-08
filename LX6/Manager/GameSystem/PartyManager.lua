-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\PartyManager.lua
-- Decompiled from: 02199_PartyManager.lua_56c339a120ec.luajit

C_PartyManager = DefClass("C_PartyManager", C_PartyManager, nil, )
local M = C_PartyManager
local PartyConfig = LTConfig.PartyConfig
local LivehouseConfig = LTConfig.LivehouseConfig
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local GeneralModelConfig = LTConfig.GeneralModelConfig
local PARTY_LIVE_CHANNEL = 100001
local PARTY_REDDOT_PREFS_KEY = "PartyRedDotV2"
local PARTY_TYPE_REDDOT_PREFIX = "Party.Type:"
local PARTY_DANCE_BODY_TYPE_NAME = {
	"3$",
	"-$",
	",$",
	"3/",
	"-/",
	",/"
}
local PARTY_DANCE_BODY_TYPE_ORDER = {
	["-$"] = 2,
	["-/"] = 4,
	[",/"] = 3,
	["3/"] = 5,
	[",$"] = 1
}
local TIMELINE_BINDING_TYPE_PLAYER = 0
local TIMELINE_BINDING_TYPE_NPC = 2

local getPartyDanceBodyTypeName = function(unit)
	local modelCfg = GeneralModelConfig.GetConfig(unit.ClientData.ModelId)

	return modelCfg and PARTY_DANCE_BODY_TYPE_NAME[modelCfg.BodyType] or nil
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self:CreateAction("OnBeforeSwitchScene"))
	gMessageManager:AddMessageListener(gEventConstants.PLAYER_INFO_INIT, self:CreateAction("SyncPartyRedDot"))

	self.partyDanceFloorStates = {}
	self.partyDanceCountdowns = {}
	self.partyDanceActive = {}
end

M.GetPartyRedDotData = function(self)
	local prefsKey = gClientUtils.GetPrefsKey(PARTY_REDDOT_PREFS_KEY)

	if self.partyRedDotPrefsKey == prefsKey then
		self.partyRedDotPrefsKey = prefsKey
		self.partyRedDotData = gUIUtils:LoadJsonToLuaTableWithPid(PARTY_REDDOT_PREFS_KEY) or {}
		self.partyRedDotData.unlocked = self.partyRedDotData.unlocked or {}
		self.partyRedDotData.types = self.partyRedDotData.types or {}
	end

	return self.partyRedDotData
end

M.SavePartyRedDotData = function(self)
	gUIUtils:SaveLuaTableToJsonWithPid(PARTY_REDDOT_PREFS_KEY, self:GetPartyRedDotData())
end

M.GetPartyTypeRedDotKey = function(self, typeId, isOnline)
	return ("%s%d:%d"):format(PARTY_TYPE_REDDOT_PREFIX, isOnline and 1 or 0, typeId)
end

M.CheckHasNewPartyRedDot = function(self)
	return next(self:GetPartyRedDotData().types) == nil
end

M.RefreshPartyRedDot = function(self)
	local data = self:GetPartyRedDotData()
	local typeRedDotKeySet = {}

	for i = 0, PartyConfig.count - 1 do
		local partyCfg = PartyConfig.LoadAt(i)
		local typeRedDotKey = self:GetPartyTypeRedDotKey(partyCfg.Type, partyCfg.OnlineParty)
		typeRedDotKeySet[typeRedDotKey] = true
	end

	for typeRedDotKey in pairs(typeRedDotKeySet) do
		SGUI.RedDotMgr.LuaSetRedDot(data.types[typeRedDotKey] ~= true, typeRedDotKey)
	end

	gMainPhoneUtils.RefreshAppItemRedDot(LTConfig.MobileMenuSGuiConfig.Party)
end

M.MarkPartyTypeRedDotRead = function(self, typeId, isOnline)
	local data = self:GetPartyRedDotData()
	local key = self:GetPartyTypeRedDotKey(typeId, isOnline)

	if data.types[key] then
		data.types[key] = nil

		self:SavePartyRedDotData()
		self:RefreshPartyRedDot()
	end
end

M.SyncPartyRedDot = function(self)
	local data = self:GetPartyRedDotData()
	local initialized = data.initialized ~= true
	local changed = false

	for i = 0, PartyConfig.count - 1 do
		local partyCfg = PartyConfig.LoadAt(i)
		local key = tostring(partyCfg.Id)

		if gEventConditionUtils.CheckHasUnlocked(partyCfg, UX.Game.EventConditionImplModule.Party) and not data.unlocked[key] then
			data.unlocked[key] = true

			if initialized then
				data.types[self:GetPartyTypeRedDotKey(partyCfg.Type, partyCfg.OnlineParty)] = true
			end

			changed = true
		end
	end

	if not initialized then
		data.initialized = true
		changed = true
	end

	if changed then
		self:SavePartyRedDotData()
	end

	self:RefreshPartyRedDot()
end

M.OnPartyUnlocked = function(self, partyIdList)
	local data = self:GetPartyRedDotData()
	local changed = false

	for _, partyId in ipairs(partyIdList) do
		local partyCfg = PartyConfig.GetConfig(partyId)
		local key = tostring(partyId)

		if partyCfg and not data.unlocked[key] then
			data.unlocked[key] = true
			data.types[self:GetPartyTypeRedDotKey(partyCfg.Type, partyCfg.OnlineParty)] = true
			local typeCfg = LTConfig.PartyPartyTypeConfig.GetConfig(partyCfg.Type)

			gNewPopupManager:PushPopup(LTConfig.PopupConfig.NewParty, {
				PopupPic = typeCfg.IconId,
				PopupName = typeCfg.Name,
				PopupContent = partyCfg.Location
			})

			changed = true
		end
	end

	if changed then
		self:SavePartyRedDotData()
		self:RefreshPartyRedDot()
	end
end

M.OnBeforeSwitchScene = function(self, _, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType ~= gSwitchSceneType.KickToLogin then
		self:Clear()
	end
end

M.Clear = function(self)
	gTimelineManager:Timeline_Stop("play_party_end")

	local player = gCS.MyPlayerManager.PlayerUnit

	if player then
		gTimelineManager:Timeline_StopLink(player.Pid, "ol_play_party_end")
	end

	self.isInParty = nil
	self.singlePartyId = nil
	self.partyOverTime = nil
	self.lotteryStartTime = nil
	self.lotteryItemId = nil
	self.lotteryItemCount = nil
	self.lotteryParticipants = nil
	self.lotteryResults = nil

	self:ClearPartyLiveChat()

	self.partyResponseNpcInfoList = nil
	self.partyInviteNpcIdList = nil
	self.partyLiveNpcBlacklist = nil

	self:ClearPartyDance()
	gLinkManager:EndOfSearching()
end

M.IsPartyLiveChannel = function(self, topChannelId, subChannelId)
	return topChannelId ~= gSocialChatManager.ChatTopChannel.Channels and subChannelId ~= PARTY_LIVE_CHANNEL
end

M.AddPartyLiveNpcToBlacklist = function(self, npcId)
	self.partyLiveNpcBlacklist = self.partyLiveNpcBlacklist or {}
	self.partyLiveNpcBlacklist[npcId] = true
end

M.BlockPartyLiveNpc = function(self, npcId)
	gClientToGameDelegate:SendPartyEvent(LTConfig.PartyPartyEventConfig.BlockViewer, npcId).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		self:AddPartyLiveNpcToBlacklist(npcId)
	end
end

M.IsPartyLiveNpcBlocked = function(self, npcId)
	return self.partyLiveNpcBlacklist and self.partyLiveNpcBlacklist[npcId] ~= true
end

M.SetPartyLiveChatActive = function(self, active)
	self.partyLiveChatActive = active ~= true

	if self.partyLiveChatActive then
		self:EnsurePartyLiveChannel()
	end
end

M.IsPartyLiveChatVisible = function(self)
	if self.partyLiveChatActive then
		return true
	end

	local channel = self:GetPartyLiveChannel()

	return channel and channel.messages and #channel.messages >= 0
end

M.ClearPartyLiveChat = function(self)
	self.partyLiveChatActive = false
	local topChannelId = gSocialChatManager.ChatTopChannel.Channels

	gSocialChatManager:ClearChannelMessages(topChannelId, PARTY_LIVE_CHANNEL)
	gSocialChatManager:ClearChannelUnread(topChannelId, PARTY_LIVE_CHANNEL)
	gSocialChatManager:ClearMemoryJumpToIfMatch(topChannelId, PARTY_LIVE_CHANNEL)

	if gSocialChatManager:IsCurrentChannel(topChannelId, PARTY_LIVE_CHANNEL) then
		gSocialChatManager:UpdateCurrentChatting(nil, )
	end

	gMessageManager:SendMessage(gEventConstants.SOCIAL_FRIEND_LATEST_MESSAGES_CHANGE)
end

M.GetPartyLiveChannel = function(self)
	return gSocialChatManager:GetChannel(gSocialChatManager.ChatTopChannel.Channels, PARTY_LIVE_CHANNEL)
end

M.EnsurePartyLiveChannel = function(self)
	local channel = self:GetPartyLiveChannel()

	if not channel then
		channel = gSocialChatManager:CreateChannelInfo()
		channel.historyState = gSocialChatManager.ChatHistoryState.Latest

		gSocialChatManager:InsertSubChannel(gSocialChatManager.ChatTopChannel.Channels, PARTY_LIVE_CHANNEL, channel)
	end

	return channel
end

M.GetPartyLiveChannelItem = function(self)
	local channel = self:EnsurePartyLiveChannel()
	local lastMsg = channel.lastMessage
	local str = lastMsg and lastMsg.text or ""
	local timestamp = lastMsg and lastMsg.timeStamp or 0
	local cfg = LTConfig.FriendsChannelTabConfig.GetConfig(LTConfig.FriendsChannelTabConfig.CurrentLink)
	local item = gSocialChatManager:CreateChatListItem(gSocialChatManager.ChatTopChannel.Channels, PARTY_LIVE_CHANNEL, str, timestamp, self:GetPartyLiveChannelName())
	item.icon = cfg.TabIcon
	item.iconSelected = cfg.TabIconSelect
	item.isOnlineChannel = true
	item.isPartyLiveChannel = true

	return item
end

M.GetPartyLiveChannelName = function(self)
	return LTConfig.TextScriptTextConfig.GetConfig(89901504).Text
end

M.OpenPartyLiveChat = function(self)
	self:SetPartyLiveChatActive(true)
	gSocialChatManager:JumpToChat(gSocialChatManager.ChatTopChannel.Channels, PARTY_LIVE_CHANNEL)
end

M.TrySendPartyLiveChat = function(self, inputValue)
	gClientUtils.EnvSdkReviewWords(inputValue, function ()
		gClientToGameDelegate:SendPartyComment(inputValue).Callback = function (errorId)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end

			self:AppendPartyLivePlayerMessage(inputValue)
		end
	end, function ()
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.FilesCheck)
	end, "PartyLive")
end

M.AppendPartyLivePlayerMessage = function(self, message)
	self:SetPartyLiveChatActive(true)

	local chatInfo = gSocialChatManager:GetChatInfo()
	chatInfo.timeStamp = gCS.TimeManager:GetClientMilliSeconds()
	chatInfo.topChannelId = gSocialChatManager.ChatTopChannel.Channels
	chatInfo.subChannelId = PARTY_LIVE_CHANNEL
	chatInfo.str = message
	chatInfo.msgMode = gSocialChatManager.MsgMode.Text
	chatInfo.senderName = gPlayerManager.infoLogin.bindData.playerName
	chatInfo.senderId = gPlayerManager.infoLogin.bindData.pid
	local msg = gSocialChatManager:InitChatMsg(chatInfo)

	gSocialChatManager:RecycleChatInfo(chatInfo)

	if msg then
		gSocialChatManager:ShowNewChat(msg, false, gSocialChatManager.ChatMessageSource.Local)
		self:TrimPartyLiveMessages()
	end
end

M.AppendPartyLiveNpcMessages = function(self, npcMessageList, npcInfoMap)
	if not npcMessageList or #npcMessageList ~= 0 then
		return
	end

	self:SetPartyLiveChatActive(true)

	for _, npcMessage in ipairs(npcMessageList) do
		local npcInfo = npcInfoMap[npcMessage.Id]

		if npcInfo and not self:IsPartyLiveNpcBlocked(npcMessage.Id) then
			local chatInfo = gSocialChatManager:GetChatInfo()
			chatInfo.timeStamp = gCS.TimeManager:GetClientMilliSeconds()
			chatInfo.topChannelId = gSocialChatManager.ChatTopChannel.Channels
			chatInfo.subChannelId = PARTY_LIVE_CHANNEL
			chatInfo.str = npcMessage.Message
			chatInfo.msgMode = gSocialChatManager.MsgMode.Text
			chatInfo.senderName = npcInfo.NickName
			chatInfo.senderId = 0
			local msg = gSocialChatManager:InitChatMsg(chatInfo)

			gSocialChatManager:RecycleChatInfo(chatInfo)

			if msg then
				msg.templateMode = gSocialChatManager.ChatMsgTemplateMode.TheirChat
				msg.partyLiveNpcInfo = {
					npcId = npcMessage.Id,
					nickName = npcInfo.NickName,
					iconId = npcInfo.iconId
				}

				gSocialChatManager:ShowNewChat(msg, false, gSocialChatManager.ChatMessageSource.Local)
			end
		end
	end

	self:TrimPartyLiveMessages()
end

M.TrimPartyLiveMessages = function(self)
	local channel = self:GetPartyLiveChannel()
	local maxCount = PartyConfig.MaxCommentNum

	if not channel or not maxCount or maxCount < 0 then
		return
	end

	while maxCount >= #channel.messages do
		local msg = table.remove(channel.messages, 1)
		channel.messageDict[msg.msgId] = nil
	end
end

M.ClearPartyDance = function(self)
	self.isInPartyDance = nil
	self.partyDanceZoneGadgetUId = nil
	self.partyDanceMusicId = nil
	self.partyDanceMode = nil
	self.partyDancePartnerPid = nil
	self.partyDanceStartInfo = nil
	self.partyDanceFloorStates = {}
	self.partyDanceCountdowns = {}
	self.partyDanceActive = {}
	self.myPartyDanceGadgetId = nil
end

M.ClearPartyDanceZone = function(self, zoneGadgetUId)
	self.partyDanceFloorStates[zoneGadgetUId] = nil
	self.partyDanceCountdowns[zoneGadgetUId] = nil
	self.partyDanceActive[zoneGadgetUId] = nil

	if self.partyDanceZoneGadgetUId ~= zoneGadgetUId then
		self.isInPartyDance = nil
		self.partyDanceZoneGadgetUId = nil
		self.partyDanceMusicId = nil
		self.partyDanceMode = nil
		self.partyDancePartnerPid = nil
		self.partyDanceStartInfo = nil
	end

	if self.myPartyDanceGadgetId ~= zoneGadgetUId then
		self.myPartyDanceGadgetId = nil
	end
end

M.OnSyncPartyDanceInvite = function(self, info)
	gMessageManager:SendMessage(gEventConstants.ON_SYNC_PARTY_DANCE_INVITE, info)
end

M.OnSyncPartyDanceSongRecommend = function(self, musicId)
	gMessageManager:SendMessage(gEventConstants.ON_SYNC_PARTY_DANCE_SONG_RECOMMEND, musicId)
end

M.OnSyncPartyDanceStart = function(self, info)
	local zoneGadgetUId = info.ZoneGadgetUId
	self.partyDanceActive[zoneGadgetUId] = info
	self.partyDanceCountdowns[zoneGadgetUId] = nil
	local floorState = self.partyDanceFloorStates[zoneGadgetUId]
	local selfPid = self:GetSelfPid()
	local isParticipant = ulong.equals(zoneGadgetUId, 0) or floorState and (ulong.equals(floorState.Slot1.Pid, selfPid) or ulong.equals(floorState.Slot2.Pid, selfPid))

	if isParticipant then
		self.isInPartyDance = true
		self.partyDanceStartInfo = info
		self.partyDanceZoneGadgetUId = zoneGadgetUId
		self.partyDanceMusicId = info.MusicId
		self.partyDanceMode = info.Mode
		self.myPartyDanceGadgetId = zoneGadgetUId
	end

	gMessageManager:SendMessage(gEventConstants.ON_SYNC_PARTY_DANCE_START, info)
end

M.OnSyncPartyDanceEnd = function(self, zoneGadgetUId)
	self:ClearPartyDanceZone(zoneGadgetUId)
	gMessageManager:SendMessage(gEventConstants.ON_SYNC_PARTY_DANCE_END, zoneGadgetUId)
end

M.OnSyncPartyDancePartnerState = function(self, partnerPid, state)
	gMessageManager:SendMessage(gEventConstants.ON_SYNC_PARTY_DANCE_PARTNER_STATE, {
		partnerPid = partnerPid,
		state = state
	})
end

M.OnSyncPartyDanceSettle = function(self, info)
	local musicId = self.partyDanceMusicId

	self:ClearPartyDanceZone(info.ZoneGadgetUId)
	gMessageManager:SendMessage(gEventConstants.ON_SYNC_PARTY_DANCE_SETTLE, info)
end

M.OnSyncPartyDanceFloorState = function(self, state)
	local zoneGadgetUId = state.ZoneGadgetUId
	self.partyDanceFloorStates[zoneGadgetUId] = state
	local selfPid = self:GetSelfPid()

	if ulong.equals(state.Slot1.Pid, selfPid) or ulong.equals(state.Slot2.Pid, selfPid) then
		self.myPartyDanceGadgetId = zoneGadgetUId
	elseif self.myPartyDanceGadgetId ~= zoneGadgetUId then
		self.myPartyDanceGadgetId = nil
	end

	if state.Status == UX.Game.PartyDanceFloorStatus.Waiting or state.Slot2.Status == UX.Game.PartyDanceSlotStatus.Ready then
		self.partyDanceCountdowns[zoneGadgetUId] = nil
	end

	gMessageManager:SendMessage(gEventConstants.ON_SYNC_PARTY_DANCE_FLOOR_STATE, state)
end

M.OnSyncPartyDanceFloorCountdown = function(self, zoneGadgetUId, totalSeconds, startTimestamp)
	local countdown = {
		zoneGadgetUId = zoneGadgetUId,
		totalSeconds = totalSeconds,
		startTimestamp = startTimestamp
	}
	self.partyDanceCountdowns[zoneGadgetUId] = countdown

	gMessageManager:SendMessage(gEventConstants.ON_SYNC_PARTY_DANCE_FLOOR_COUNTDOWN, countdown)
end

M.GetPartyLivehouseConfigByMusicId = function(self, musicId)
	for index = 0, LivehouseConfig.count - 1 do
		local cfg = LivehouseConfig.LoadAt(index)

		if cfg == nil and cfg.Use ~= LivehouseConfig.UseType.Party and not table.isNilOrEmpty(cfg.Difficulty) then
			for i = 1, #cfg.Difficulty do
				local diff = cfg.Difficulty[i]

				if diff.MusicConfigID ~= musicId then
					return cfg, diff
				end
			end
		end
	end
end

M.IsPartyLivehouseMusic = function(self, musicId)
	local livehouseCfg = self:GetPartyLivehouseConfigByMusicId(musicId)

	return livehouseCfg == nil
end

M.GetPartyLivehouseGameplayTimelineName = function(self, gameCfg, musicId, invitePid)
	if not self:IsPartyLivehouseMusic(musicId) then
		return nil
	end

	local timelineName = gameCfg and gameCfg.TimeineName or nil

	if timelineName == "play_party_swing" or not invitePid or invitePid ~= 0 then
		return timelineName
	end

	local playerUnit = gCS.MyPlayerManager.PlayerUnit
	local inviteUnit = gCS.SceneDataMgr.GetUnit(invitePid)

	if not playerUnit or not inviteUnit then
		return timelineName
	end

	local playerBodyTypeName = getPartyDanceBodyTypeName(playerUnit)
	local inviteBodyTypeName = getPartyDanceBodyTypeName(inviteUnit)
	local playerOrder = PARTY_DANCE_BODY_TYPE_ORDER[playerBodyTypeName]
	local inviteOrder = PARTY_DANCE_BODY_TYPE_ORDER[inviteBodyTypeName]

	if not playerOrder or not inviteOrder then
		return timelineName
	end

	local bodyTypeSuffix = playerOrder >= inviteOrder and playerBodyTypeName .. inviteBodyTypeName or inviteBodyTypeName .. playerBodyTypeName
	local playerBindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, playerUnit.Pid, playerBodyTypeName, nil, , TIMELINE_BINDING_TYPE_PLAYER)
	local inviteBindType = inviteUnit.IsPlayer and TIMELINE_BINDING_TYPE_PLAYER or TIMELINE_BINDING_TYPE_NPC
	local inviteBindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, invitePid, inviteBodyTypeName, nil, , inviteBindType)

	return "play_dance_swing_" .. bodyTypeSuffix, {
		playerBindInfo,
		inviteBindInfo
	}
end

M.CanPlayLivehouseIntro = function(self, musicId, introTimelineName)
	return not self:IsPartyLivehouseMusic(musicId) and not string.is_null_or_empty(introTimelineName)
end

M.ShouldPlayLivehouseIntro = function(self, musicId, isFirstPlay, introTimelineName)
	return isFirstPlay and self:CanPlayLivehouseIntro(musicId, introTimelineName)
end

M.ShouldSkipLivehouseEndTimeline = function(self, musicId)
	return self:IsPartyLivehouseMusic(musicId)
end

M.GetPartyDanceLiveHouseParams = function(self, musicId)
	local cfg, diff = self:GetPartyLivehouseConfigByMusicId(musicId)

	if cfg and diff then
		return {
			liveHouseId = cfg.Id,
			musicId = musicId,
			difficulty = diff.Difficulty
		}
	end
end

M.ShowPartyDanceSettlePanel = function(self, musicId)
	local playInfo = self:GetPartyDanceLiveHouseParams(musicId)

	if not playInfo then
		print_error("PartyDance settle music config missing, musicId = " .. tostring(musicId))

		return
	end

	gPanelManager:CheckShow(gPanelId.LIVEHOUSE_GAME_END_PANEL, {
		id = playInfo.musicId,
		liveHouseId = playInfo.liveHouseId,
		difficulty = playInfo.difficulty
	})
end

M.StartSingleParty = function(self, partyId, npcIdList)
	if not partyId then
		return
	end

	self:SetSinglePartyId(partyId)

	npcIdList = npcIdList or {}

	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.PartyChangeCloth, function ()
		gPanelManager:Close(gPanelId.PARTY_START_PANEL)
		self:RequestStartSingleParty(partyId, npcIdList, nil, true)
	end, function ()
		local partyCfg = PartyConfig.GetConfig(partyId)

		gPanelManager:Close(gPanelId.PARTY_START_PANEL)
		gDressManager:EnterChangeFashion({
			partyId = partyId,
			fashionChangeType = gClientConst.FashionChangeType.Rent,
			spiritList = self:GetSinglePartySpiritList(npcIdList),
			tagIdList = {
				partyCfg.SuitTag
			},
			rentCb = function (rentMap)
				self:RequestStartSingleParty(partyId, npcIdList, rentMap)
			end
		})
	end)
end

M.EnterPartyChangeFashion = function(self)
	local partyId, params = nil

	if gClientUtils.CheckIsLinkMode() then
		local partyInfo = gCustomRoomMgr:GetPartyInfo()

		if not partyInfo then
			return
		end

		partyId = partyInfo.PartyConfigId
		params = {
			fashionChangeType = gClientConst.FashionChangeType.Party
		}
	else
		partyId = self.singlePartyId
		params = {
			partyId = partyId,
			fashionChangeType = gClientConst.FashionChangeType.Rent,
			spiritList = self:GetSinglePartySpiritList(self:GetPartyNpcInfoList())
		}
	end

	if not partyId then
		return
	end

	local partyCfg = PartyConfig.GetConfig(partyId)
	params.tagIdList = {
		partyCfg.SuitTag
	}
	params.partyId = partyId

	gDressManager:EnterChangeFashion(params)
end

M.GetSinglePartySpiritList = function(self, npcIdList)
	local spiritList = {
		gCS.MyPlayerManager.PlayerUnit.ClientData.cardId
	}

	for _, npcId in ipairs(npcIdList) do
		local npcCfg = NpcCultivationConfig.GetConfig(npcId)

		table.insert(spiritList, npcCfg.FightSpiritID)
	end

	return spiritList
end

M.RequestStartSingleParty = function(self, partyId, npcIdList, rentMap, useDefault)
	local fashionsInfo = nil

	if useDefault then
		fashionsInfo = {
			["A\\xef\"\\xc8,1.\\xd6m4\\xf3J\\x9fK\\xc9\\xe8"] = true,
			Rents = {}
		}
	elseif rentMap and next(rentMap) then
		fashionsInfo = {
			Rents = rentMap
		}
	end

	self.partyInviteNpcIdList = self:CopyRpcList(npcIdList)

	gClientToGameDelegate:StartSingleParty(partyId, npcIdList, fashionsInfo).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		self.isInParty = true

		gPanelManager:CheckShow(gPanelId.PARTY_HUD_PANEL)
	end
end

M.OnSyncResponse = function(self, response, npcIdList)
	self.partyResponseNpcInfoList = self:CopyRpcList(npcIdList)

	gMessageManager:SendMessage(gEventConstants.ON_SYNC_PARTY_RESPONSE, {
		response = response,
		npcIdList = self.partyResponseNpcInfoList
	})
end

M.GetPartyNpcInfoList = function(self)
	return self.partyInviteNpcIdList or {}
end

M.GetPartyKickPlayerInfoList = function(self)
	local roomInfo = gCustomRoomMgr:GetRoomInfo()
	local myPid = gPlayerManager.infoLogin.bindData.pid
	local list = {}

	if roomInfo and roomInfo.Members then
		for _, member in ipairs(roomInfo.Members) do
			if member.PlayerInfo.Pid == myPid then
				table.insert(list, member.PlayerInfo)
			end
		end
	end

	return list
end

M.PreparePartyEnd = function(self)
	self:Clear()
	gPanelManager:Close(gPanelId.PARTY_HUD_PANEL)
	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_ENTRANCE_PANEL)
	gPanelManager:Close(gPanelId.PARTY_NPC_INVITE)
	gPanelManager:Close(gPanelId.S_FASHION_DETAIL_PANEL)
end

M.ClosePartyEndPanel = function(self)
	if gPanelManager:IsPanelShowing(gPanelId.PARTY_END_PANEL) then
		gPanelManager:Close(gPanelId.PARTY_END_PANEL)
	end
end

M.OnSyncSettleData = function(self, settleData)
	self:PreparePartyEnd()

	local openPartyEndPanel = function()
		gPanelManager:CheckShow(gPanelId.PARTY_END_PANEL, settleData)
	end

	if gClientUtils.CheckIsLinkMode() then
		local onlineResult = settleData.OnlineSettleResult
		local player = gCS.MyPlayerManager.PlayerUnit
		local playerTransform = player.PlayerObj
		local timelineData = gTimelineManager:Timeline_CreateTimelineData()
		timelineData.source = 2
		timelineData.owner = player
		timelineData.linkType = 5
		timelineData.linkPidList = {
			LX6.TimelineScript.TimelineUtils.Bridge_GetUnitPidByPlayerPid(settleData.HostPid),
			LX6.TimelineScript.TimelineUtils.Bridge_GetUnitPidByPlayerPid(onlineResult.FashionStarPid),
			LX6.TimelineScript.TimelineUtils.Bridge_GetUnitPidByPlayerPid(onlineResult.SuperGamerPid),
			LX6.TimelineScript.TimelineUtils.Bridge_GetUnitPidByPlayerPid(onlineResult.PopularityKingPid)
		}
		timelineData.pos = playerTransform.position
		timelineData.rot = playerTransform.eulerAngles
		timelineData.onPlayCallback = openPartyEndPanel
		timelineData.onLoadFailedCallback = openPartyEndPanel

		timelineData.onFinishCallback = function()
			self:ClosePartyEndPanel()
		end

		gTimelineManager:Timeline_LoadAndPlay("ol_play_party_end", timelineData)

		return
	end

	local timelineData = gTimelineManager:Timeline_CreateTimelineData()
	local playerTransform = gCS.MyPlayerManager.PlayerUnit.PlayerObj
	timelineData.loadFromLocal = true
	timelineData.pos = playerTransform.position
	timelineData.rot = playerTransform.eulerAngles
	timelineData.allmoveTfs = {
		playerTransform
	}
	timelineData.onPlayCallback = openPartyEndPanel
	timelineData.onLoadFailedCallback = openPartyEndPanel

	gTimelineManager:Timeline_LoadAndPlay("play_party_end", timelineData)
end

M.GetOnlinePartyPlayerPids = function(self)
	local roomInfo = gCustomRoomMgr:GetRoomInfo()
	local members = roomInfo and roomInfo.Members or {}

	return members[1] and members[1].Pid or 0, members[2] and members[2].Pid or 0, members[3] and members[3].Pid or 0, members[4] and members[4].Pid or 0
end

M.ShowPartyMultiEndPanelForGM = function(self)
	local roomInfo = gCustomRoomMgr:GetRoomInfo()
	local partyInfo = gCustomRoomMgr:GetPartyInfo()

	if not gClientUtils.CheckIsLinkMode() or not roomInfo or not partyInfo then
		print_error("PlayPartyMultiEndTimeline requires an online party")

		return
	end

	local members = roomInfo.Members or {}
	local fallbackPid = members[1] and members[1].Pid or roomInfo.OwnerPid

	gPanelManager:CheckShow(gPanelId.PARTY_END_PANEL, {
		["cUި\\x88\t\\xaa\r\\xdd\\xf1"] = 0,
		PartyId = partyInfo.PartyConfigId,
		HostPid = members[1] and members[1].Pid or fallbackPid,
		OnlineSettleResult = {
			FashionStarPid = members[2] and members[2].Pid or fallbackPid,
			SuperGamerPid = members[3] and members[3].Pid or fallbackPid,
			PopularityKingPid = members[4] and members[4].Pid or fallbackPid
		}
	})
end

M.SyncPartyPlayerLogin = function(self, info)
	self.isInParty = true
	self.singlePartyId = info.PartyId
	self.partyInviteNpcIdList = self:CopyRpcList(info.InviteNPCIds)
	self.partyOverTime = info.PartyOverTime
	self.lotteryStartTime = info.LotteryStartTime
	self.lotteryResults = self:CopyRpcList(info.LotteryResults)

	gPanelManager:CheckShow(gPanelId.PARTY_HUD_PANEL, info)
end

M.OnSyncPartyStart = function(self, partyOverTime, lotteryStartTime)
	self.partyOverTime = partyOverTime
	self.lotteryStartTime = lotteryStartTime

	gMessageManager:SendMessage(gEventConstants.ON_SYNC_PARTY_START, {
		partyOverTime = partyOverTime,
		lotteryStartTime = self.lotteryStartTime
	})
end

M.OnSyncLotteryCountdown = function(self, itemId, itemCount, participants)
	self.lotteryItemId = itemId
	self.lotteryItemCount = itemCount
	self.lotteryParticipants = self:CopyRpcList(participants)
	local panelData = self:BuildLotteryPanelData()

	self:ShowOrUpdateLotteryPanel(panelData)
	gMessageManager:SendMessage(gEventConstants.ON_SYNC_LOTTERY_COUNTDOWN, panelData)
end

M.OnSyncLotteryResult = function(self, results)
	self.lotteryResults = self:CopyRpcList(results)
	local panelData = self:BuildLotteryPanelData(self.lotteryResults)

	self:ShowOrUpdateLotteryPanel(panelData)
	gMessageManager:SendMessage(gEventConstants.ON_SYNC_LOTTERY_RESULT, {
		results = self.lotteryResults
	})
end

M.GetLotteryParticipantCount = function(self, roomInfo, partyInfo)
	local count = 0
	slot4 = ipairs
	slot6 = roomInfo.Members or {}

	for _, member in slot4(slot6) do
		if tostring(member.Pid) == tostring(roomInfo.OwnerPid) then
			count = count + 1
		end
	end

	return count
end

M.IsLotteryGuestEnough = function(self, roomInfo, partyInfo)
	return self:GetLotteryParticipantCount(roomInfo, partyInfo or roomInfo.PartyInfo or {}) < (PartyConfig.MinGuestForLottery or 1)
end

M.ShouldHideLotteryForMinGuest = function(self, roomInfo, partyInfo)
	if not roomInfo then
		return false
	end

	partyInfo = partyInfo or roomInfo.PartyInfo or {}

	if not partyInfo.Lottery then
		return false
	end

	local lotteryStartTime = self.lotteryStartTime or 0

	if lotteryStartTime > 0 or gLuaDataManager.serverTime >= lotteryStartTime then
		return false
	end

	return not self:IsLotteryGuestEnough(roomInfo, partyInfo)
end

M.ShouldShowLottery = function(self, roomInfo, partyInfo)
	partyInfo = partyInfo or roomInfo and roomInfo.PartyInfo or {}

	return partyInfo.Lottery and not self:ShouldHideLotteryForMinGuest(roomInfo, partyInfo)
end

M.CloseLotteryPanelIfMinGuestNotEnough = function(self, roomInfo, partyInfo)
	roomInfo = roomInfo or gCustomRoomMgr:GetRoomInfo()
	partyInfo = partyInfo or roomInfo and roomInfo.PartyInfo or gCustomRoomMgr:GetPartyInfo()

	if not self:ShouldHideLotteryForMinGuest(roomInfo, partyInfo) then
		return false
	end

	local panelId = gPanelId.LOTTERY_PANEL

	if not panelId then
		return false
	end

	if not gPanelManager.IsPanelShowing or gPanelManager:IsPanelShowing(panelId) then
		gPanelManager:Close(panelId)
	end

	return true
end

M.ShouldHideLotterySettingItem = function(self, roomInfo, partyInfo)
	partyInfo = partyInfo or {}

	if not roomInfo or not partyInfo.Lottery or roomInfo.Status == UX.Game.CustomRoomStatus.Playing then
		return false
	end

	if self:ShouldHideLotteryForMinGuest(roomInfo, partyInfo) then
		return true
	end

	local partyStartTime = roomInfo.CurrentStatusOverTime - PartyConfig.OnlinePartyMaxTime
	local partyEndTime = partyStartTime + 6000

	return partyEndTime - gLuaDataManager.serverTime > PartyConfig.OnlineLotteryTime
end

M.CopyRpcList = function(self, list)
	if not list then
		return {}
	end

	if type(list) ~= "table" then
		return list
	end

	if list.ToTable then
		return list:ToTable()
	end

	local ret = {}

	if list.Count then
		for i = 0, list.Count - 1 do
			table.insert(ret, list[i])
		end
	end

	return ret
end

M.BuildLotteryPanelData = function(self, results)
	local itemId = self.lotteryItemId
	local itemCount = self.lotteryItemCount

	if results and results[1] then
		itemId = itemId or results[1].ItemId
		itemCount = itemCount or #results
	end

	return {
		itemId = itemId,
		itemCount = itemCount,
		lotteryStartTime = self.lotteryStartTime,
		participants = self:BuildLotteryParticipants(results),
		results = results or {},
		isHost = gCustomRoomMgr and gCustomRoomMgr:IsOwner(),
		selfPid = self:GetSelfPid(),
		resultHostDescFormat = PartyConfig.LotteryResultHostDesc,
		onStartLottery = function ()
			self:StartPartyLottery()
		end,
		updateEventId = gEventConstants.ON_LOTTERY_PANEL_DATA_UPDATE
	}
end

M.BuildLotteryParticipants = function(self, results)
	local participants = self.lotteryParticipants or {}

	if #participants >= 0 or not results or #results ~= 0 then
		return participants
	end

	local pidDict = {}
	local ret = {}

	for _, result in ipairs(results) do
		local pid = result.Pid
		local key = tostring(pid)

		if not pidDict[key] then
			pidDict[key] = true

			table.insert(ret, pid)
		end
	end

	return ret
end

M.GetSelfPid = function(self)
	if gPlayerManager and gPlayerManager.infoLogin and gPlayerManager.infoLogin.bindData then
		return gPlayerManager.infoLogin.bindData.pid
	end
end

M.StartPartyLottery = function(self)
	if not self:IsLotteryGuestEnough(gCustomRoomMgr:GetRoomInfo()) then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.PartyLotteryWaitForMore, nil, , PartyConfig.MinGuestForLottery or 1)

		return
	end

	gClientToGameDelegate:StartPartyLottery().Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)
		end
	end
end

M.ShowOrUpdateLotteryPanel = function(self, panelData)
	if self:CloseLotteryPanelIfMinGuestNotEnough() then
		return
	end

	local panelId = gPanelId.LOTTERY_PANEL

	if not panelId then
		print_error("gPanelId.LOTTERY_PANEL missing, generate PanelConfig for S_LotteryPanel first")

		return
	end

	if gPanelManager.IsPanelShowing and gPanelManager:IsPanelShowing(panelId) then
		gMessageManager:SendMessage(gEventConstants.ON_LOTTERY_PANEL_DATA_UPDATE, panelData)
	else
		gPanelManager:CheckShow(panelId, panelData)
	end
end

M.SetSinglePartyId = function(self, partyId)
	self.singlePartyId = partyId
end

gPartyManager = gPartyManager or C_PartyManager.new()
