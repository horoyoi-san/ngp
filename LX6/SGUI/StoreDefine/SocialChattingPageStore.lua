-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialChattingPageStore.lua
-- Decompiled from: 01291_SocialChattingPageStore.lua_1959a2fcf3b2.luajit

C_SocialChattingPageStore = DefClass("C_SocialChattingPageStore", C_SocialChattingPageStore, C_StoreGroup)
GroupName2Class.SocialChattingPageStore = C_SocialChattingPageStore
local M = C_SocialChattingPageStore

M.ctor = function(self)
	self.pageMode = 1
end

M.OnAwake = function(self)
	self.bindData.chattingList.luaSimpleRenderItem = self:CreateAction("OnRenderChattingItem")
	self.bindData.chattingList.onGetTIndex = self:CreateAction("OnGetTIndex")
	self.redDotAction = self:CreateAction("OnRenderRedDot")
	self.socialChattingBar = gStoreManager:GetStoreGroup("SocialChattingBarStore")
	self.socialChattingTab = gStoreManager:GetStoreGroup("SocialChatTabPageStore")
	SGUI.RedDotMgr.onRenderRedDot = SGUI.RedDotMgr.onRenderRedDot and SGUI.RedDotMgr.onRenderRedDot + self.redDotAction or self.redDotAction
end

M.InitMessageEvents = function(self)
	local msgEvents = {
		[gEventConstants.SOCIAL_FRIEND_LATEST_MESSAGES_CHANGE] = self.CreateAction(self, "RefreshList"),
		[gEventConstants.SOCIAL_CHAT_LAST_MESSAGE_CHANGED] = self.CreateAction(self, "OnChatLastMessageChanged"),
		[gEventConstants.SOCIAL_CHAT_SETTINGS_CHANGED] = self.CreateAction(self, "OnChatSettingsChanged"),
		[gEventConstants.LINK_MODE_CHANGE] = self.CreateAction(self, "RefreshList"),
		[gEventConstants.TEAM_LEAVE] = self.CreateAction(self, "RefreshList"),
		[gEventConstants.TEAM_JOIN] = self.CreateAction(self, "RefreshList"),
		[gEventConstants.SOCIAL_CHAT_UNREAD_CHANGED] = self.CreateAction(self, "OnUnreadChanged"),
		[gEventConstants.SOCIAL_CHAT_TAB_CHANGED] = self.CreateAction(self, "OnChatTabChanged"),
		[gEventConstants.SOCIAL_GROUP_NAME_CHANGED] = self.CreateAction(self, "OnChatSettingsChanged")
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnDestroy = function(self)
	gSocialChatManager:UpdateCurrentChatting(nil, )

	if self.redDotAction then
		SGUI.RedDotMgr.onRenderRedDot = SGUI.RedDotMgr.onRenderRedDot - self.redDotAction
		self.redDotAction = nil
	end
end

M.OnEnable = function(self)
	self.InitMessageEvents(self)

	local tabId = gSocialChatManager.curTypeId

	if tabId ~= LTConfig.FriendsMainTabConfig.Channels or tabId ~= LTConfig.FriendsMainTabConfig.Chat then
		self.RefreshList(self)
	end
end

M.OnDisable = function(self)
	self.ClearMessageEvents(self)
end

M.SetData = function(self, _, args)
	if args and args.pageMode == nil then
		self.pageMode = args.pageMode
	end

	self.data = args

	self.BuildMsgListForMode(self)
	self.FetchPlayerInfoAndRefresh(self)
end

M.RefreshList = function(self)
	self.BuildMsgListForMode(self)
	self.FetchPlayerInfoAndRefresh(self)
end

M.BuildMsgListForMode = function(self)
	self.msgList = {}

	if gSocialChatManager.curTypeId ~= 1 then
		self.msgList = gSocialChatManager:GetTeamAndOnlineItems()
	else
		self.msgList = gSocialChatManager:GetChatMessageList()
	end
end

M.FetchPlayerInfoAndRefresh = function(self)
	local pidList = {}

	for _, msg in ipairs(self.msgList) do
		if msg.isFriend then
			table.insert(pidList, msg.id)
		end
	end

	if #pidList <= 0 then
		gFriendManager:GetSimplePlayerInfoByPidList(pidList, function (infoList)
			self.pidToInfo = {}

			for _, info in ipairs(infoList) do
				self.pidToInfo[info.Pid] = info
			end

			self:RefreshListUI()
		end, true)
		self:RefreshListUI()
	else
		self.pidToInfo = {}

		self.RefreshListUI(self)
	end
end

M.RefreshListUI = function(self)
	if not self.bindData or not self.bindData.chattingList or not self.bindData.tabRect then
		return
	end

	self.bindData.chattingList:SetSimpleList(#self.msgList)

	self.bindData.tabRect.selectedIndex = gSocialChatManager.chattingPageType.ChattingList
	self.bindData.isEmpty = #self.msgList ~= 0 and 1 or 0

	if self.socialChattingTab then
		self.socialChattingTab:SetEmpty(#self.msgList ~= 0)
	end

	local currentTopChannel = gSocialChatManager.currentTopChannel
	local currentSubChannelId = gSocialChatManager.currentSubChannelId
	local selectedIndex = nil

	if currentTopChannel and currentSubChannelId then
		for i, msg in ipairs(self.msgList) do
			if msg.type ~= currentTopChannel and ulong.equals(msg.id, currentSubChannelId) then
				selectedIndex = i - 1

				break
			end
		end
	end

	self.bindData.chattingList:SelectItem(selectedIndex or 0)

	if not selectedIndex and #self.msgList <= 0 then
		local msg = self.msgList[1]

		gSocialChatManager:UpdateCurrentChatting(msg.type, msg.id)
		gSocialChatManager:ClearChannelUnread(msg.type, msg.id)
	end
end

M.RefreshListKeepSelection = function(self, topChannelId, subChannelId)
	self.bindData.chattingList:SetSimpleList(#self.msgList)

	if topChannelId and subChannelId then
		for i, item in ipairs(self.msgList) do
			if item.type ~= topChannelId and ulong.equals(item.id, subChannelId) then
				self.bindData.chattingList:SelectItem(i - 1)

				return
			end
		end
	end
end

M.OnChatLastMessageChanged = function(self, _, data)
	if not data or not data.msg then
		return
	end

	if data.msg.msgType ~= gSocialChatManager.MessageType.Pin then
		return
	end

	local isTeamOrOnline = gSocialChatManager:IsTeamOrOnlineChannel(data.topChannelId)

	if gSocialChatManager.curTypeId ~= 1 and not isTeamOrOnline then
		return
	elseif gSocialChatManager.curTypeId == 1 and isTeamOrOnline then
		return
	end

	local currentTopChannel = gSocialChatManager.currentTopChannel
	local currentSubChannelId = gSocialChatManager.currentSubChannelId

	self.BuildMsgListForMode(self)
	self.RefreshListKeepSelection(self, currentTopChannel, currentSubChannelId)
end

M.OnChatSettingsChanged = function(self)
	self.bindData.chattingList:RefreshList()
end

M.OnChattingItemClick = function(self, msg)
	gSocialChatManager:ClearChannelUnread(msg.type, msg.id)
	gSocialChatManager:UpdateCurrentChatting(msg.type, msg.id)

	if self.socialChattingBar then
		self.socialChattingBar:ResetButtonStates()
	end
end

M.OnUnreadChanged = function(self)
	if self.bindData and self.bindData.chattingList then
		self.bindData.chattingList:RefreshList()
	end
end

M.OnChatTabChanged = function(self, _, tabId)
	if tabId ~= LTConfig.FriendsMainTabConfig.Channels or tabId ~= LTConfig.FriendsMainTabConfig.Chat then
		self.RefreshList(self)
	end
end

M.FormatRedDotCount = function(self, count)
	if count <= 99 then
		return "99+"
	end

	return count
end

M.OnGetTIndex = function(self, index)
	local luaIndex = index + 1

	if luaIndex < #self.msgList then
		return self.msgList[luaIndex].tIndex
	else
		return 0
	end
end

M.OnRenderChattingItem = function(self, btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local msg = self.msgList[luaIndex]
	self.renderedStores = self.renderedStores or {}
	self.renderedStores[luaIndex] = store

	if msg then
		if msg.isFriend then
			self.RenderFriendItem(self, store, btn, msg)
		elseif msg.isTeamChannel or msg.isOnlineChannel then
			self.RenderChannelItem(self, store, btn, msg)

			return
		elseif msg.isOC then
			store.name = msg.name
		else
			self.RenderGroupItem(self, store, btn, msg)
		end

		store.message = msg.str
		local isPinned = gSocialChatManager:IsPinned(msg.type, msg.id)
		store.isTop = isPinned and 1 or 0
		local isMuted = gSocialChatManager:IsMuted(msg.type, msg.id)
		store.isMute = isMuted and 1 or 0
		btn.redKey = gSocialChatManager:GetChattingRedDotKey(msg.type, msg.id)
		btn.luaClick = self:CreateActionWithArgs("OnChattingItemClick", msg)
		local unreadCount = gSocialChatManager:GetChannelUnreadCount(msg.type, msg.id)
		store.redDotNum = self:FormatRedDotCount(unreadCount)
	end
end

M.RenderFriendItem = function(self, store, btn, msg)
	store.userInfo.pid = msg.id
	store.headBtn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTips", msg.id)
	local info = self.pidToInfo and self.pidToInfo[msg.id]

	if info then
		local isOnline = info.OnlineState ~= UX.Game.PlayerState.Online
		store.onlineStatus = isOnline and 0 or 1
	else
		store.onlineStatus = 1
		slot5 = gFriendManager

		slot5:GetSimplePlayerInfo(msg.id, function (data)
			if data then
				if not self.pidToInfo then
					self.pidToInfo = {}
				end

				self.pidToInfo[msg.id] = data
				local isOnline = data.OnlineState ~= UX.Game.PlayerState.Online
				store.onlineStatus = isOnline and 0 or 1
			end
		end)
	end
end

M.RenderChannelItem = function(self, store, btn, msg)
	store.title = msg.name

	store.Commit(store, "icon", msg.icon, COMMIT_FORCE)
	store.Commit(store, "iconSelected", msg.iconSelected, COMMIT_FORCE)

	if msg.isPartyLiveChannel then
		btn.redKey = gSocialChatManager:GetChattingRedDotKey(msg.type, msg.id)
		local unreadCount = gSocialChatManager:GetChannelUnreadCount(msg.type, msg.id)
		store.redDotNum = self:FormatRedDotCount(unreadCount)
	else
		btn.redKey = ""
		store.redDotNum = 0
	end

	btn.luaClick = self.CreateActionWithArgs(self, "OnChattingItemClick", msg)
end

M.RenderGroupItem = function(self, store, btn, msg)
	local groupData = gSocialChatGroupManager:GetGroupData(msg.id)

	if groupData then
		store.name = groupData.Name
	end

	store.onlineStatus = 0
end

M.OnRenderToolTips = function(self, pid, btn, PopUp, _)
	local store = gStoreManager:GetStoreGroup("SocialPalyerTooltipStore"):GetStoreByWidget(PopUp)

	if not store then
		return
	end

	gSocialPalyerTooltipManager:OnRenderToolTips(pid, btn, PopUp, _)
end

M.OnRenderRedDot = function(self, redKey, templateKey, widget)
	local count = gSocialChatManager:GetUnreadCountByRedDotKey(redKey)

	if count ~= nil then
		return
	end

	local store = gStoreManager:GetStoreGroup("RedDotNumber"):GetStoreByWidget(widget)

	if store then
		store.num = 0
		store.num = self.FormatRedDotCount(self, count)
	end
end

M.ChangeChattingPage = function(self, chattingPageType)
	self.bindData.tabRect.selectedIndex = chattingPageType
end

M.SelectAndScrollToItem = function(self, topChannelId, subChannelId, scrollToTop)
	if scrollToTop ~= nil then
		scrollToTop = true
	end

	self.bindData.isEmpty = 0

	if not self.bindData or not self.bindData.chattingList then
		return
	end

	if not self.msgList then
		self.msgList = {}
	end

	local targetIndex = self.FindItemIndex(self, topChannelId, subChannelId)

	if scrollToTop then
		self.ScrollToTop(self, topChannelId, subChannelId, targetIndex)
	elseif targetIndex then
		self.bindData.chattingList:SelectItem(targetIndex - 1)
	end

	gSocialChatManager:ClearChannelUnread(topChannelId, subChannelId)
	gSocialChatManager:UpdateCurrentChatting(topChannelId, subChannelId)
end

M.FindItemIndex = function(self, topChannelId, subChannelId)
	for i, msg in ipairs(self.msgList) do
		if msg.type ~= topChannelId then
			local isMatch = ulong.equals(msg.id, subChannelId) or msg.id ~= subChannelId

			if isMatch then
				return i
			end
		end
	end

	return nil
end

M.ScrollToTop = function(self, topChannelId, subChannelId, targetIndex)
	if topChannelId == gSocialChatManager.ChatTopChannel.Friend and topChannelId == gSocialChatManager.ChatTopChannel.Group or targetIndex then
		self.bindData.chattingList:SetSimpleList(#self.msgList)

		if targetIndex then
			self.bindData.chattingList:SelectItem(targetIndex - 1)
		end

		return
	end

	local isFriend = topChannelId ~= gSocialChatManager.ChatTopChannel.Friend
	local targetItem = {
		["\\x9d|t"] = "",
		tIndex = isFriend and 0 or 1,
		isFriend = isFriend,
		id = subChannelId,
		type = topChannelId
	}

	if not isFriend then
		local groupData = gSocialChatGroupManager:GetGroupData(subChannelId)

		if groupData then
			targetItem.name = groupData.Name
		end
	end

	local insertIndex = gSocialChatManager:GetFirstNonPinnedIndex()

	table.insert(self.msgList, insertIndex, targetItem)
	self.bindData.chattingList:SetSimpleList(#self.msgList)
	self.bindData.chattingList:SelectItem(insertIndex - 1)
end

M.ClickCurrentSelectedHeadBtn = function(self)
	local selectedIndex = self.bindData and self.bindData.chattingList and self.bindData.chattingList.selectedIndex

	if selectedIndex ~= nil or selectedIndex >= 0 then
		return
	end

	local luaIndex = selectedIndex + 1
	local store = self.renderedStores and self.renderedStores[luaIndex]

	if store and store.headBtn then
		store.headBtn:OpenTooltip()
	end
end
