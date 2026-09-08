-- Original chunk: @Lua\LuaFiles\LX6\GUI\Chat\ChatUtils.lua
-- Decompiled from: 00294_ChatUtils.lua_e5b4474230c1.luajit

local ChatUtils = {}
local this = ChatUtils
local cs = L50.Chat.ChatUtils
ChatUtils.GmUtils = require("LX6/GUI/Chat/ChatUtils_GmUtils")

ChatUtils.MakeInviteNpcView = function(npcTemplateId, npcChatInfo, npcCardInfo)
	local view = {
		subChannelId = npcTemplateId,
		name = npcChatInfo:GetName(),
		showFavor = true,
		isOnline = true,
		favorLevel = this.GetFavorLevel(npcCardInfo.Favor),
		favorViewInfo = this.GetFavorViewInfo(npcTemplateId)
	}

	gChatManager:SetHeadIcon(view, nil, , npcChatInfo:GetIcon())

	return view
end

ChatUtils.GetFavorLevel = function(favor)
	for i = 1, #LTConfig.NpcCultivationConfig.FavorLevel do
		if favor >= LTConfig.NpcCultivationConfig.FavorLevel[i] then
			return i - 1
		end
	end

	return #LTConfig.NpcCultivationConfig.FavorLevel
end

ChatUtils.HasNextMessage = function(msg)
	if msg.npcNextChatId <= 0 then
		return true
	end

	local cfg = LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)

	if cfg ~= nil or table.isNilOrEmpty(cfg.NextMessage) then
		return false
	end

	if cfg.ChatGroup <= 0 then
		local groupCfg = LTConfig.NPCChatGroupConfig.GetConfig(cfg.ChatGroup)

		if not groupCfg then
			return false
		end

		if not table.isNilOrEmpty(groupCfg.GroupMember) then
			return true
		end

		local members = gChatManager.groupInviteList

		if table.isNilOrEmpty(members) then
			return false
		end

		for _, chatId in pairs(cfg.NextMessage) do
			local chatCfg = LTConfig.NPCChatConfig.GetConfig(chatId)

			if chatCfg and table.contains(members, chatCfg.NPCid) then
				return true
			end
		end

		return false
	end

	return true
end

ChatUtils.IsNextNpcMessage = function(msg)
	if msg.npcNextChatId <= 0 then
		return true
	end

	local lastChatCfg = msg.cfg

	if lastChatCfg and lastChatCfg.NextMessage and #lastChatCfg.NextMessage ~= 1 then
		local nextChatCfg = LTConfig.NPCChatConfig.GetConfig(lastChatCfg.NextMessage[1])

		if not nextChatCfg.IsPlayerMessage then
			return true
		end
	end

	return false
end

ChatUtils.IsNpcChannel = function(topChannelId)
	return topChannelId ~= gChatTopChannel.Npc or topChannelId ~= gChatTopChannel.NpcGroup
end

ChatUtils.IsPlayerChannel = function(topChannelId)
	return topChannelId ~= gChatTopChannel.Friend or topChannelId ~= gChatTopChannel.Channels
end

ChatUtils.CheckIsValidChatCfgOnShowNpcNewChat = function(cfg)
	if cfg ~= nil then
		return false
	end

	local isGroup = cfg.ChatGroup >= 0
	local id = isGroup and cfg.ChatGroup or cfg.NPCid

	if id ~= nil or id ~= 0 then
		print_error("NPCChat表NPCid或ChatGroup字段空了！！！！id：", cfg.Id)

		return false
	end

	if not isGroup then
		local info = gDialogMainChatManager:GetNpcChatInfo(cfg.NPCid)

		if info ~= nil then
			return false
		end
	end

	return true
end

ChatUtils.OpenPersonalPage = function(pid)
	pid = pid or gPlayerManager.infoBase.bindData.Pid

	gHunLunManager:InitPersonalInfo(nil, function ()
		local store = this.GetBasePanelStore()

		store:ShowFragment(gChatConst.TabShowType.PersonalPage, {
			pid = pid
		})
	end)
end

ChatUtils.OpenNpcPersonalPage = function(npcId, noChatBtn)
	local store = this.GetBasePanelStore()

	store.ShowFragment(store, gChatConst.TabShowType.PersonalPage, {
		npcId = npcId,
		noChatBtn = noChatBtn
	})
end

ChatUtils.GetMySignature = function()
	local roleInfo = gHunLunManager.roleInfo or {}

	if table.isNilOrEmpty(roleInfo) then
		return
	end

	return string.is_null_or_empty(roleInfo.sign) and LTConfig.FriendsConfig.DefaultPersonalSignature or roleInfo.sign
end

ChatUtils.GetPlayerSignature = function(pid, callback, default)
	if pid ~= nil then
		callback(default or "")

		return
	end

	local targetId = ulong.tonum2(pid)
	slot4 = gHunLunManager

	slot4:GetPersonalInfo(targetId, function (data)
		local signature = data and data.Signature

		if string.is_null_or_empty(signature) then
			callback(default or "")
		else
			callback(signature)
		end
	end)
end

ChatUtils.SetSignature = function(topChannel, subChannel, setter)
	if topChannel ~= gChatTopChannel.Friend then
		setter(LTConfig.NPCChatConfig.DefaultPlayerSignature)
		this.GetPlayerSignature(subChannel, setter, LTConfig.NPCChatConfig.DefaultPlayerSignature)
	elseif topChannel ~= gChatTopChannel.Npc then
		local npcInfo = gDialogMainChatManager:GetNpcChatInfo(subChannel)
		local signature = npcInfo:GetSignature()

		if string.is_null_or_empty(signature) then
			setter(LTConfig.NPCChatConfig.DefaultPlayerSignature)
		else
			setter(signature)
		end
	end
end

ChatUtils.SetHeader = function(headerWidget, showMyInfo, topChannel, subChannel)
	local headerStore = gStoreManager:GetStoreGroup("ChatHeaderStore"):GetStoreByWidget(headerWidget)

	if showMyInfo then
		local info = gPlayerManager.infoLogin.bindData
		headerStore.name = info.name

		this.SetSignature(gChatTopChannel.Friend, info.pid, function (signature)
			headerStore.signature = signature
		end)

		local senderId = ChatSenderId.NewPlayer(info.pid)

		gChatAvatarUtils:SetSingleAvatar(senderId, headerStore.avatar)

		return
	end

	headerStore.signature = ""
	headerStore.showTypeCtrl = 0

	gChatAvatarUtils:SetChannelAvatar(topChannel, subChannel, headerStore.avatar)

	if topChannel ~= gChatTopChannel.Friend then
		slot5 = gChatManager
		local chatterInfo = slot5:GetChatterInfo(subChannel)
		headerStore.name = chatterInfo.name

		this.SetSignature(topChannel, subChannel, function (signature)
			headerStore.signature = signature
		end)
	elseif topChannel ~= gChatTopChannel.Npc then
		local npcInfo = gDialogMainChatManager:GetNpcChatInfo(subChannel)

		if not npcInfo then
			print_warn("npcInfo is nil")

			return
		end

		headerStore.name = npcInfo.GetName(npcInfo)
		local signature = npcInfo.GetSignature(npcInfo)

		if string.is_null_or_empty(signature) then
			signature = LTConfig.NPCChatConfig.DefaultPlayerSignature
		end

		headerStore.signature = signature
	elseif topChannel ~= gChatTopChannel.NpcGroup then
		local cfg = LTConfig.NPCChatGroupConfig.GetConfig(subChannel)
		headerStore.name = gClientUtils.RichTextToPlain(cfg.GroupName)
		headerStore.showTypeCtrl = 2
	elseif topChannel ~= gChatTopChannel.Channels then
		headerStore.showTypeCtrl = 2
		headerStore.name = this.GetOnlineChannelName(subChannel)
	else
		print_error("ChatUtils.SetHeader: invalid topChannel", topChannel)
	end
end

ChatUtils.OpenChatPanel = function(params)
	gChatNpcsPhoneManager:Reset()

	params = this._OpenChatPanelParamsPreprocess(params)
	params.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Chat

	if params.forceShow and this.IsNeedShowFrontFullscreen(params) then
		if not gPanelManager:IsPanelShowing(gPanelId.S_FRONT_FULLSCREEN_PHONE_APP_HOME_PANEL) then
			local panelIdList = gClientUtils.GetMainPhonePanelIdList()

			for _, panelId in ipairs(panelIdList) do
				if panelIdList == gPanelId.S_FRONT_FULLSCREEN_PHONE_APP_HOME_PANEL and gPanelManager:IsPanelShowing(panelId) then
					gPanelManager:Close(panelId)
				end
			end
		end

		gPanelManager:CheckShow(gPanelId.S_FRONT_FULLSCREEN_PHONE_APP_HOME_PANEL, params)
	else
		gMainPhoneUtils.ShowPhoneAppContent(params)
	end
end

ChatUtils.IsNeedShowFrontFullscreen = function(params)
	if gMainPhoneUtils.IsFakePhoneExist() then
		return false
	end

	if params.npcInviteGamePlay then
		return true
	end

	if params.chatCfg and params.chatCfg.Id ~= 84013630 then
		return true
	end

	if gTimelineManager:Timeline_IsPlaying() then
		return true
	end

	return false
end

ChatUtils._OpenChatPanelParamsPreprocess = function(params)
	params = params or {}

	local SetParams = function(key, value, ...)
		if params[key] and params[key] == value then
			print_error(gString.FormatString("OpenChatPanel: params.{0} not match value! params.{0} = {1}, value = {2}", key, params[key], value), ...)
		end

		params[key] = value
	end

	local top = params.topChannelId
	local sub = params.subChannelId
	local chatCfg = params.chatCfg or LTConfig.NPCChatConfig.GetConfig(params.chatCfgId)

	if chatCfg then
		if chatCfg.ChatGroup ~= 0 then
			top = gChatTopChannel.Npc
			sub = chatCfg.NPCid
		else
			top = gChatTopChannel.NpcGroup
			sub = chatCfg.ChatGroup
		end

		local chatCfgId = chatCfg.Id

		SetParams("npcChatType", chatCfg.ChatType, "id = " .. tostring(chatCfgId))
	end

	top = top or gChatManager:GetNewestUnreadChannel()

	if top ~= nil then
		top, sub = gChatManager:GetRecordChannel()
	end

	top = top or gChatTopChannel.Npc

	if sub and chatCfg ~= nil and gChatManager:GetChannel(top, sub) ~= nil then
		print_error("OpenChatPanel: sub channel not exist", "top", top, "sub", sub)

		sub = nil
	end

	if gChatUtils.IsStoryChannel(top) or params.npcInviteGamePlay then
		local npcChatType = params.npcChatType or LTConfig.NPCChatConfig.ChatTypeType.Normal

		if params.npcInviteGamePlay then
			npcChatType = LTConfig.NPCChatConfig.ChatTypeType.Invite
		end

		gChatManager.currentNpcChatType = npcChatType
	elseif params.npcChatType then
		print_error("OpenChatPanel: topChannelId is not NPC or NPCGroup, but npcChatType is not nil!, topChannelId:", params.topChannelId, "subChannelId:", params.subChannelId, "npcChatType:", params.npcChatType)

		params.npcChatType = nil
	end

	if gChatUtils.IsStoryChannel(top) and sub then
		local npcChatMsg = this.GetCurrentNpcChannelLastMsg(top, sub)
		local toCheckIsFakePhone = false

		if chatCfg ~= nil then
			if npcChatMsg then
				chatCfg = npcChatMsg.cfg
				params.chatCfg = chatCfg
			else
				toCheckIsFakePhone = true
			end
		end

		local npcsPhoneCfg = params.npcsPhoneCfg or this._TryGetNpcsPhoneCfg(chatCfg)

		if npcsPhoneCfg then
			gChatNpcsPhoneManager:Init(npcsPhoneCfg, chatCfg, params)
			gChatManager:GetOrAddSubChannel(top, sub)

			toCheckIsFakePhone = false
		end

		if toCheckIsFakePhone then
			print_error("OpenChatPanel: NpcChatMessage not found!!!, topChannelId", top, "subChannelId", sub)
		end
	end

	if gChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Normal then
		params.forceShow = true
	end

	SetParams("topChannelId", top, "id = " .. tostring(chatCfg and chatCfg.Id))
	SetParams("subChannelId", sub, "id = " .. tostring(chatCfg and chatCfg.Id))

	return params
end

ChatUtils._TryGetNpcsPhoneCfg = function(chatCfg)
	local count = LTConfig.NPCChatNpcsPhoneConfig.count

	for i = 0, count - 1 do
		local npcPhoneCfg = LTConfig.NPCChatNpcsPhoneConfig.LoadAt(i)

		if table.find(npcPhoneCfg.ChatList, chatCfg.Id) then
			return npcPhoneCfg
		end
	end
end

ChatUtils.SortSubChannelItems = function(items)
	table.sort(items, function (a, b)
		if a.info and b.info then
			if a.info.OnlineState == b.info.OnlineState then
				return a.info.OnlineState <= b.info.OnlineState
			elseif a.info.OnlineState ~= UX.Game.PlayerState.Online then
				return ulong.Less(a.subChannelId, b.subChannelId)
			else
				return b.info.LastLogoutTime <= a.info.LastLogoutTime
			end
		end

		if a.timeStamp == b.timeStamp then
			return b.timeStamp <= a.timeStamp
		else
			return ulong.Less(a.subChannelId, b.subChannelId)
		end
	end)
end

ChatUtils.SetCloseType = function(...)
	local store = this.GetBasePanelStore()

	store.SetCloseType(store, ...)
end

ChatUtils.ShowPhoneAppTip = function(text)
	local store = this.GetBasePanelStore()

	store.ShowMessage(store, text)
end

ChatUtils.GetCurrentCloseType = function()
	local store = this.GetBasePanelStore()

	return store.closeType, store.customCloseFunc
end

ChatUtils.GetCurrentNpcChannelLastMsg = function(top, sub)
	if not top or not sub then
		top, sub = gChatManager:GetCurrentChannel()
	end

	return cs.GetCurrentNpcChannelLastMsg(top, sub)
end

ChatUtils.GetBasePanelStore = function()
	return gStoreManager:GetStoreGroup("ChatBasePanelStore")
end

ChatUtils.IsChatPanelShowing = function()
	local basePanelStore = this.GetBasePanelStore()

	return basePanelStore and gClientUtils.NotNil(basePanelStore.rootWidget) and basePanelStore.rootWidget.activation
end

ChatUtils.GetMainPhonePanelId = function()
	if gPanelManager:IsPanelShowing(gPanelId.S_FRONT_FULLSCREEN_PHONE_APP_HOME_PANEL) then
		return gPanelId.S_FRONT_FULLSCREEN_PHONE_APP_HOME_PANEL
	end

	return gClientUtils.GetMainPhonePanelId()
end

ChatUtils.GetNextNpcChatId = function(msg)
	if msg.npcNextChatId <= 0 then
		return msg.npcNextChatId
	end

	local lastChatCfg = msg.cfg

	if lastChatCfg and lastChatCfg.NextMessage and #lastChatCfg.NextMessage ~= 1 then
		return lastChatCfg.NextMessage[1]
	end

	return 0
end

ChatUtils.IsStoryChannel = function(topChannelId)
	return topChannelId ~= gChatTopChannel.Npc or topChannelId ~= gChatTopChannel.NpcGroup
end

ChatUtils.IsOnlineChannel = function(topChannelId)
	return topChannelId ~= gChatTopChannel.Friend or topChannelId ~= gChatTopChannel.Channels or topChannelId ~= gChatTopChannel.Group
end

ChatUtils.GetOnlineChannelName = function(subChannel)
	if subChannel ~= UX.Game.MessageChannel.Room then
		return "组队频道"
	end
end

ChatUtils.GetFavorViewInfo = function(npcCultivationId)
	local favorInfo = gNpcFavorManager:GetSpiritFavorInfo(npcCultivationId)

	if table.isNilOrEmpty(favorInfo) then
		print_error("GetFavorViewInfo not found! npcCultivationId:", npcCultivationId)

		return nil
	end

	local result = {
		favorNum = favorInfo.favorLevel,
		favorFillAmount = favorInfo.favorAmount
	}

	return result
end

ChatUtils.SetChatChannelCardBaseView = function(btn, topChannelId, subChannelId)
	if gClientUtils.IsNil(btn) then
		print_error("@liulijun04 SetChatChannelCardBaseView btn is nil")

		return
	end

	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)
	local store = storeGroup and storeGroup:GetStoreByWidget(btn)

	if store ~= nil then
		print_error("@liulijun04 SetChatChannelCardBaseView btn.Store is nil!, btn", btn.name)
	end

	gChatAvatarUtils:SetChannelAvatar(topChannelId, subChannelId, store.avatar)
end

ChatUtils.NotImplementedHint = function()
	gDisplayMessageMgr:ShowMessage(65401046)
end

ChatUtils.ShowPhoneAppTipCs = function(self, text)
	self.ShowPhoneAppTip(text)
end

ChatUtils.CloseMainPhonePanelCs = function(self)
	gClientUtils.CloseMainPhonePanel()
end

ChatUtils.IsChatPanelShowingCs = function(self)
	return self.IsChatPanelShowing()
end

ChatUtils.OpenChatPanelCs = function(self, ...)
	self.OpenChatPanel(...)
end

ChatUtils.HasNextMessageCs = function(self, ...)
	return self.HasNextMessage(...)
end

ChatUtils.OpenGroupSettingPage = function(groupData)
	local store = this.GetBasePanelStore()

	store.ShowFragment(store, gChatConst.TabShowType.GroupSetting, groupData)
end

ChatUtils.OpenGroupPage = function(TabShowType, data)
	local store = this.GetBasePanelStore()

	store.ShowFragment(store, TabShowType, data)
end

gChatUtils = this
