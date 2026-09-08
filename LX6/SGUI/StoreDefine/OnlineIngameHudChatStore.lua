-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineIngameHudChatStore.lua
-- Decompiled from: 01110_OnlineIngameHudChatStore.lua_5157dba73e29.luajit

local LinkConfig = LTConfig.LinkConfig
local ClickEventListener = SGUI.EventSystems.ClickEventListener
C_OnlineIngameHudChatStore = DefClass("C_OnlineIngameHudChatStore", C_OnlineIngameHudChatStore, C_StoreGroup)
GroupName2Class.OnlineIngameHudChatStore = C_OnlineIngameHudChatStore
local M = C_OnlineIngameHudChatStore

M.OnAwake = function(self)
	self.msgList = {}
	self.msgCountLimit = 4
	self.topChannelId = gChatTopChannel.Channels
	self.subChannelId = UX.Game.MessageChannel.PublicLink

	if self.bindData.chatBtn then
		self.bindData.chatBtn.luaClick = self.CreateAction(self, "OnChatBtnClick")
	end

	if self.bindData.chatBtn2 then
		self.bindData.chatBtn2.luaClick = self.CreateAction(self, "OnChatBtnClick")
	end

	if self.bindData.chatBtnPad then
		self.bindData.chatBtnPad.luaLongPress = self.CreateAction(self, "OnChatBtnClick")
	end

	if self.bindData.chatMobileBtn then
		self.bindData.chatMobileBtn.luaClick = self.CreateAction(self, "OnChatBtnClick")
	end

	self.bindData.chatList.luaRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.chatList.onGetTIndex = self.CreateAction(self, "OnGetTIndex")
	local msgEvents = {
		[gEventConstants.SOCIAL_CHAT_INGAME_NEW_MESSAGE_RECEIVED] = self.CreateAction(self, "OnSocialChatMessageChanged"),
		[gEventConstants.LINK_MODE_CHANGE] = self.CreateAction(self, "OnLinkModeChange"),
		[gEventConstants.PANEL_ON_CLOSE] = self.CreateAction(self, "OnPanelClose"),
		[gEventConstants.SYNC_WATCH_INTERACTION_INFO] = self.CreateAction(self, "SyncWatchInteractionInfo"),
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self.CreateAction(self, "OnPhoneShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self.CreateAction(self, "OnPhoneHide"),
		[gEventConstants.SOCIAL_FRIEND_UPDATE_APPLICATION_COUNT] = self.CreateAction(self, "RefreshRedDot")
	}

	self.SetCurChannel(self)
	self.RegisterMessageEvents(self, msgEvents)

	self.bindData.hideThis = 1

	if self.bindData.chatBtnRedDot then
		self.bindData.chatBtnRedDot.redKey = gSocialChatManager:GetHudChatRedDotKey()
	end
end

M.OnGroupEnable = function(self)
	self.interactionStore = gStoreManager:GetStoreGroup("WatchingGameInteractionStore")
end

M.OnGroupDisable = function(self)
	self.interactionStore = nil
end

M.RefreshRedDot = function(self)
	gSocialChatManager:RefreshHudChatRedDot()
end

M.OnDestroy = function(self)
	if self.countDown then
		self.countDown:Stop()

		self.countDown = nil
	end

	if self.waitTimer then
		self.waitTimer:Stop()

		self.waitTimer = nil
	end

	self.ClearMessageEvents(self)
end

M.OnSocialChatMessageChanged = function(self, _, data)
	if data.isHistory then
		return
	end

	local subChannelId = ulong.check(data.subChannelId) and ulong.tonum2(data.subChannelId) or data.subChannelId

	if gSocialChatManager:IsMuted(data.topChannelId, subChannelId) then
		return
	end

	if data.topChannelId ~= gChatTopChannel.Friend and gSocialFriendManager:IsInBlackList(subChannelId) then
		return
	end

	if self.topChannelId ~= data.topChannelId and self.subChannelId ~= subChannelId then
		self.HideThisCountDown(self)
		self.AddNewChatMessage(self, data.msg, data.topChannelId, subChannelId)
	elseif data.topChannelId ~= gChatTopChannel.Team then
		self.HideThisCountDown(self)
		self.AddNewChatMessage(self, data.msg, data.topChannelId, subChannelId)
	elseif data.topChannelId ~= gChatTopChannel.Friend then
		if self.subChannelId ~= UX.Game.MessageChannel.PublicLink or self.subChannelId ~= UX.Game.MessageChannel.PrivateLink then
			self.HideThisCountDown(self)
			self.AddNewChatMessage(self, data.msg, data.topChannelId, subChannelId)
		else
			gSocialChatManager:RefreshHudChatRedDot()
		end
	end
end

M.HideThisCountDown = function(self)
	self.bindData.hideThis = 0

	if self.countDown then
		self.countDown:Stop()

		self.countDown = nil
	end

	self.countDown = Timer.New(function ()
		self.bindData.hideThis = 1
	end, LTConfig.LinkConfig.ChatBubbleFloatingTime):Start()
end

M.OnPanelClose = function(self, eventId, panelId)
	if panelId ~= gPanelId.S_HALF_PHONE_APP_HOME_PANEL then
		self.SetCurChannel(self)
	end
end

M.OnLinkModeChange = function(self)
	if not gLinkManager:CheckInLinkMode() then
		return
	end

	self.SetCurChannel(self)
end

M.SetCurChannel = function(self)
	if gLinkManager.LinkMode ~= UX.Game.LinkMode.Private then
		self.subChannelId = UX.Game.MessageChannel.PrivateLink
	elseif gLinkManager.LinkMode ~= UX.Game.LinkMode.Public then
		self.subChannelId = UX.Game.MessageChannel.PublicLink
	elseif gLinkManager.LinkMode ~= UX.Game.LinkMode.Match then
		self.subChannelId = UX.Game.MessageChannel.MatchLink
	end

	gChatManager:GetOrAddSubChannel(self.topChannelId, self.subChannelId)
	gChatManager:UpdateCurrentChannel(self.topChannelId, self.subChannelId)
end

M.AddNewChatMessage = function(self, msg, topChannelId, subChannelId)
	self.HideThisCountDown(self)

	if self.msgCountLimit < #self.msgList then
		table.remove(self.msgList, 1)
	end

	msg._topChannelId = topChannelId
	msg._subChannelId = subChannelId

	table.insert(self.msgList, msg)
	self.bindData.chatList:SetList(#self.msgList)
	self.bindData.chatList:ScrollToBottom(true)
end

M.AddShortChatEmoji = function(self, pid, imageId)
	if not imageId or imageId ~= 0 then
		print_notice("[ShortChatEmoji] invalid hud chat imageId")

		return
	end

	self.AddNewChatMessage(self, {
		pid = pid,
		msgType = gSocialChatManager.MessageType.Emoji,
		imageId = imageId
	}, self.topChannelId, self.subChannelId)
end

M.OnRenderItem = function(self, btn, csIndex)
	local msg = self.msgList[csIndex + 1]
	local msgType = msg.msgType

	if msgType ~= gSocialChatManager.MessageType.Emoji then
		self.OnRenderEmoji(self, btn, csIndex)
	else
		self.OnRenderText(self, btn, csIndex)
	end
end

M.OnRenderText = function(self, btn, csIndex)
	local msg = self.msgList[csIndex + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local playerName = gFriendManager:GetPlayerRealName(msg.pid)
	local msgText = msg.text

	if msg.msgType ~= gChatConst.MessageType.Team then
		msgText = LTConfig.TextCommonTextConfig.GetConfig(LTConfig.TextCommonTextConfig.HUDChatBoxTeamInvite).Text
	elseif msg.msgType ~= gSocialChatManager.MessageType.CustomInvite then
		msgText = LTConfig.TextCommonTextConfig.GetConfig(LTConfig.TextCommonTextConfig.HUDChatBoxGameInvite).Text
	end

	local formatText = self.GetFormatText(self, msg)
	store.content = gString.Format(formatText, playerName, msgText)

	if store.clickEventListener then
		local clickEventListener = ClickEventListener.Get(store.clickEventListener.gameObject)
		clickEventListener.onClick = self.CreateActionWithArgs(self, "OnChatAreaClick", msg)
	end
end

M.OnRenderEmoji = function(self, btn, csIndex)
	local msg = self.msgList[csIndex + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local playerName = gFriendManager:GetPlayerRealName(msg.pid)
	local formatText = self:GetFormatText(msg)
	store.name = gString.Format(formatText, playerName, "")
	local imageId = msg.imageId

	if store.rawImage and imageId and imageId == 0 then
		local imagePath = gUIUtils:GetSguiImagePath(imageId)

		if not string.is_null_or_empty(imagePath) then
			slot9 = store.rawImage

			slot9:SetUrlWithCallback(imagePath, function ()
			end)
		else
			print_notice("[ShortChatEmoji] hud chat image path is empty, imageId = ", imageId)
		end

		return
	end

	local emojiUrl = msg.emojiUrl

	if store.rawImage and not string.is_null_or_empty(emojiUrl) then
		slot9 = gSocialFriendManager

		slot9:DownloadImage(emojiUrl, function (tex)
			if tex and store.rawImage then
				store.rawImage.texture = tex
			end
		end, nil, true)
	end
end

M.GetFormatText = function(self, msg)
	local formatText = "%s: %s"

	if msg._topChannelId ~= gChatTopChannel.Friend then
		formatText = LTConfig.TextScriptTextConfig.GetConfig(89901369).Text
	elseif msg._topChannelId ~= gChatTopChannel.Team then
		formatText = LTConfig.TextScriptTextConfig.GetConfig(89901370).Text
	elseif msg._subChannelId ~= UX.Game.MessageChannel.PrivateLink then
		formatText = LTConfig.TextScriptTextConfig.GetConfig(89901372).Text
	elseif msg._subChannelId ~= UX.Game.MessageChannel.PublicLink then
		formatText = LTConfig.TextScriptTextConfig.GetConfig(89901371).Text
	end

	return formatText
end

M.OnGetTIndex = function(self, csIndex)
	local msg = self.msgList[csIndex + 1]
	local msgType = msg.msgType

	if msgType ~= gSocialChatManager.MessageType.Emoji then
		return 1
	end

	return 0
end

M.GetLinkIndex = function(self, pid)
	return gLinkManager.LinkMemberIndex[gLinkManager.LinkMode][pid] or 0
end

M.ContentIsEmpty = function(self, str)
	for i = 1, #str do
		if string.sub(str, i, i) == "\n" and string.sub(str, i, i) == " " then
			return false
		end
	end

	return true
end

M.OpenChatPanel = function(self, topChannelId, subChannelId)
	if topChannelId and subChannelId then
		gSocialChatManager:JumpToChat(topChannelId, subChannelId)
	else
		gSocialChatManager:OpenChatUI()
	end
end

M.OnChatBtnClick = function(self)
	self.HideThisCountDown(self)

	if self.bindData.hideThis ~= 1 then
		self.bindData.hideThis = 0

		return
	end

	self.OpenChatPanel(self)
end

M.OnChatAreaClick = function(self, msg)
	self:OpenChatPanel(msg and msg._topChannelId, msg and msg._subChannelId)
end

M.OnPhoneShow = function(self, _, data)
	self.bindData.hideAll = 1
end

M.OnPhoneHide = function(self, _, data)
	self.bindData.hideAll = 0
end

M.SyncWatchInteractionInfo = function(self, _, data)
	if data.type ~= LTConfig.LinkInteractionConfig.BeWatched then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Link_WatchingGame_Enter, nil, , gSocialFriendManager:GetPlayerDisplayName(data.pid, data.name))
	elseif data.type ~= LTConfig.LinkInteractionConfig.ExitWatching then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Link_WatchingGame_Exit, nil, , gSocialFriendManager:GetPlayerDisplayName(data.pid, data.name))
	else
		self.interactionStore:SetData(data)
	end
end
