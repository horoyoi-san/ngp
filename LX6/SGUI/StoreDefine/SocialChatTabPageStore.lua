-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialChatTabPageStore.lua
-- Decompiled from: 01310_SocialChatTabPageStore.lua_cd61964d4069.luajit

C_SocialChatTabPageStore = DefClass("C_SocialChatTabPageStore", C_SocialChatTabPageStore, C_StoreGroup)
GroupName2Class.SocialChatTabPageStore = C_SocialChatTabPageStore
local M = C_SocialChatTabPageStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.OnAwake = function(self)
	self.PageType = {
		["\\xfa\\xf3530\\xdd"] = 0,
		[":z\\xb8\\xab\\xade"] = 2,
		["Y\n\\o"] = 1,
		["+\\xcdi>\\xf5#\\x90s\\x88s\\x9e\\x92"] = 3
	}
	self.defaultSelect = 2
	local device = gCS.LuaUtils.GetActiveDevice()

	if gCS.LuaUtils.IsOnPS5 or device ~= SGUI.GameDevice.PlayStation or device ~= SGUI.GameDevice.Xbox then
		self.currTabLv1List = self.bindData.tabLv1ListController
	else
		self.currTabLv1List = self.bindData.tabLv1List
	end

	self.bindData.tabLv1List.luaSimpleRenderItem = self.CreateAction(self, "OnTabRenderItem")
	self.bindData.tabLv1ListController.luaSimpleRenderItem = self.CreateAction(self, "OnTabRenderItem")
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")
	self.bindData.L1Btn.luaClick = self.CreateAction(self, "OnL1BtnClick")
	self.bindData.L2Btn.luaClick = self.CreateAction(self, "OnL2BtnClick")
	self.bindData.btnSetting.luaClick = self.CreateAction(self, "OnSettingBtnClick")
	self.curPage = self.defaultSelect
end

M.SetData = function(self, args)
	self.panelArgs = args

	self.InitTabData(self)
	self.SelectInitialTab(self, args)
	self.HandleJumpToChat(self, args)
end

M.SelectInitialTab = function(self, args)
	local tabId = args and args.tabId

	if args and args.topChannelId and gSocialChatManager:IsTeamOrOnlineChannel(args.topChannelId) then
		tabId = LTConfig.FriendsMainTabConfig.Channels
	end

	local targetIndex = self:FindTabIndexById(tabId)
	self.curSelectItem = targetIndex or #self.tabTypeList - 1

	self.currTabLv1List:SetSimpleList(#self.tabTypeList)
	self.currTabLv1List:SelectItem(self.curSelectItem)
	self:OnTabItemClick(self.curSelectItem)

	if args and args.topChannelId and args.subChannelId then
		gSocialChatManager:UpdateCurrentChatting(args.topChannelId, args.subChannelId)
	end

	local selectedData = self.tabTypeList[self.curSelectItem + 1]
	self.bindData.tabRect.selectedIndex = selectedData.type

	gSocialChatManager:SetCurrentTabId(selectedData.id)
end

M.FindTabIndexById = function(self, tabId)
	if not tabId then
		return nil
	end

	for i, data in ipairs(self.tabTypeList) do
		if data.id ~= tabId then
			return i - 1
		end
	end

	return nil
end

M.HandleJumpToChat = function(self, args)
	if not args or not args.topChannelId or not args.subChannelId then
		return
	end

	FrameTimer.New(function ()
		local store = gSocialChatManager:GetChattingPageStore()

		if store then
			store:SelectAndScrollToItem(args.topChannelId, args.subChannelId)
		end
	end, 5):Start()
end

M.InitTabData = function(self)
	self.tabTypeList = {}

	for i = 0, LTConfig.FriendsMainTabConfig.count - 1 do
		local cfg = LTConfig.FriendsMainTabConfig.LoadAt(i)
		local shouldShow = cfg.Id == LTConfig.FriendsMainTabConfig.Channels or gClientUtils.CheckIsLinkMode() or gPartyManager:IsPartyLiveChatVisible()

		if shouldShow then
			local data = {
				title = cfg.TabName,
				iconId = cfg.TabIcon,
				type = cfg.TabRectIndex,
				id = cfg.Id
			}

			table.insert(self.tabTypeList, data)
		end
	end
end

M.OnRenderTab = function(self, index, widget)
	if not widget then
		return
	end

	local group = gStoreManager:GetStoreGroup(widget.Store)

	if group then
		local args = {
			pageMode = index
		}

		if self.panelArgs then
			args.topChannelId = self.panelArgs.topChannelId
			args.subChannelId = self.panelArgs.subChannelId
		end

		group.SetData(group, nil, args)
	end
end

M.OnTabRenderItem = function(self, btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local data = self.tabTypeList[luaIndex]
	store.title = data.title
	store.icon = data.iconId

	if data.id ~= LTConfig.FriendsMainTabConfig.Chat then
		btn.redKey = "SocialChat.Chat"
	elseif data.id ~= LTConfig.FriendsMainTabConfig.Friend then
		btn.redKey = "SocialChat.Friend"
	elseif data.id ~= LTConfig.FriendsMainTabConfig.Channels then
		btn.redKey = gSocialChatManager:GetChannelsTabRedDotKey()
	else
		btn.redKey = ""
	end

	btn.luaClick = self.CreateActionWithArgs(self, "OnTabItemClick", csIndex)
end

M.OnTabItemClick = function(self, csIndex)
	self:SetEmpty(false)

	local luaIndex = csIndex + 1
	local data = self.tabTypeList[luaIndex]
	gSocialChatManager.curTypeId = data.id

	gSocialChatManager:SetCurrentTabId(data.id)

	self.curPage = data.type

	if self.curPage == self.PageType.INVITE_FRIEND then
		gSocialChatManager:UpdateCurrentChatting(nil, )
	end

	if self.bindData.tabRect then
		self.bindData.tabRect.selectedIndex = data.type
	end

	self.bindData.tabTitle = data.title
	self.curSelectItem = csIndex

	gMessageManager:SendMessage(gEventConstants.SOCIAL_CHAT_TAB_CHANGED, data.id)

	local socialChattingBar = gStoreManager:GetStoreGroup("SocialChattingBarStore")

	if socialChattingBar then
		socialChattingBar.ResetButtonStates(socialChattingBar)
	end
end

M.OnL1BtnClick = function(self)
	local index = self.curSelectItem

	if index <= 0 then
		index = index - 1
	else
		index = #self.tabTypeList - 1
	end

	self.currTabLv1List:SelectItem(index)
	self:SetEmpty(false)
	self:OnTabItemClick(index)

	self.curSelectItem = index
end

M.OnL2BtnClick = function(self)
	local index = self.curSelectItem

	if index >= #self.tabTypeList - 1 then
		index = index + 1
	else
		index = 0
	end

	self.currTabLv1List:SelectItem(index)
	self:SetEmpty(false)
	self:OnTabItemClick(index)

	self.curSelectItem = index
end

M.OnSettingBtnClick = function(self)
	local store = gStoreManager:GetStoreGroup("SocialChatHomePanelStore")

	if store then
		store.OpenSettingPage(store)
	end
end

M.ChangeInviteFriendPage = function(self)
	self.SetEmpty(self, false)

	self.bindData.tabRect.selectedIndex = self.PageType.INVITE_FRIEND
end

M.ChangeCurPage = function(self)
	self.SetEmpty(self, false)

	self.bindData.tabRect.selectedIndex = self.curPage
end

M.ChangeChatPage = function(self, topChannelId)
	local targetTabId = LTConfig.FriendsMainTabConfig.Chat

	if gSocialChatManager:IsTeamOrOnlineChannel(topChannelId) then
		targetTabId = LTConfig.FriendsMainTabConfig.Channels
	end

	for i, data in ipairs(self.tabTypeList) do
		if data.id ~= targetTabId then
			gSocialChatManager.curTypeId = data.id

			gSocialChatManager:SetCurrentTabId(data.id)

			local csIndex = i - 1

			if self.currTabLv1List and not gCS.LuaUtils.IsNull(self.currTabLv1List) then
				self.currTabLv1List:SelectItem(csIndex)
			end

			self.curSelectItem = csIndex
			self.bindData.tabTitle = data.title
			self.curPage = data.type

			self.SetEmpty(self, false)

			self.bindData.tabRect.selectedIndex = data.type

			break
		end
	end
end

M.SetEmpty = function(self, isEmpty)
	self.bindData.isEmpty = BOOL2CTL[isEmpty]
end

M.OnActiveDeviceChange = function(self, device)
	if device ~= SGUI.GameDevice.PlayStation or device ~= SGUI.GameDevice.Xbox then
		self.currTabLv1List = self.bindData.tabLv1ListController
	else
		self.currTabLv1List = self.bindData.tabLv1List
	end

	self.currTabLv1List:SetSimpleList(#self.tabTypeList)
	self.currTabLv1List:SelectItem(self.curSelectItem)
end
