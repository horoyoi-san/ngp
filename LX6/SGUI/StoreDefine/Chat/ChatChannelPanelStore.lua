-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChatChannelPanelStore.lua
-- Decompiled from: 01930_ChatChannelPanelStore.lua_9e750bc95217.luajit

C_ChatChannelPanelStore = DefClass("C_ChatChannelPanelStore", C_ChatChannelPanelStore, C_AppFragmentStore)
GroupName2Class.ChatChannelPanelStore = C_ChatChannelPanelStore
local M = C_ChatChannelPanelStore

dofile("LX6/SGUI/StoreDefine/Chat/ChatChannelPanelStore_OnlinePart")
dofile("LX6/SGUI/StoreDefine/Chat/ChatChannelPanelStore_StoryPart")

M.ctor = function(self)
	self.TabDefine = {
		["!\\xecQ8\\xd3\\x86@\\xa6S\\x93\\xa5"] = 0,
		["/\\xe6L?\\xd7\\x86@\\xa6S\\x93\\xa5"] = 1,
		["\\xb213,y\\x9aD\\xe96\\xad\\xbc"] = 2,
		["\\xbc;.+y\\x9eU\\xe96\\xad\\xbc"] = 1
	}
	self.lastSelectTopChannelId = {
		[self.TabDefine.ContactPage] = nil,
		[self.TabDefine.MessagePage] = nil
	}
	self.TopBarIndex2TopChannelId = {
		gChatTopChannel.FriendList,
		gChatTopChannel.Channels,
		gChatTopChannel.Friend
	}
	self.RenderItemFunctions = {
		[gChatTopChannel.Friend] = self.OnRenderFriendItem,
		[gChatTopChannel.FriendList] = self.OnRenderFriendListItem,
		[gChatTopChannel.Group] = self.OnRenderGroupItem,
		[gChatTopChannel.Npc] = self.OnRenderNpcItem,
		[gChatTopChannel.NpcGroup] = self.OnRenderNpcGroupItem
	}
end

M.OnAwake = function(self)
	self.bindData.tabRect.OnGenerateTab = self:CreateAction(self.OnGenerateTab)
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.OnRenderTab)
	slot1 = self.bindData.tabRect

	slot1:SetActiveFastest(false)

	self.subStore = {}
	self.bindData.bottomBarBtn_Contact.luaClick = self:CreateActionWithArgs(self.OnClickBottomBarBtn, 1)
	self.bindData.bottomBarBtn_Message.luaClick = self:CreateActionWithArgs(self.OnClickBottomBarBtn, 2)
	self.bottomBarBtnList = {
		self.bindData.bottomBarBtn_Contact,
		self.bindData.bottomBarBtn_Message
	}
	self.bindData.personalPageBtn.luaClick = self:CreateAction(self.OnPersonalPageBtnClick)

	self:RegisterMessageEventHandlers()
end

M.OnShow = function(self, _, data)
	self.data = data

	self.InitUI(self)
	self.InitFriend(self)
end

M.OnEnable = function(self)
	self:InitFriend()
	FrameTimer.New(function ()
		self.bindData.signature = gChatUtils.GetMySignature()

		if self.currentTabCsIndex and self.currentTabCsIndex + 1 ~= self.TabDefine.MessagePageCs then
			self:RefreshSubChannelList(self.selectedTopBar)
		end

		if self.friendApplyCount then
			local redKey = self:GetChatTopBarBtnFriendRedDotKey()

			SGUI.RedDotMgr.LuaSetRedDot(self.friendApplyCount >= 0, redKey)
		end
	end, 3):Start()
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)

	self.subChannelItems = nil
	self.friendApplyCount = nil
end

M.HandleExit = function(self)
	self.activity:CloseThisActivity()

	return true
end

M.InitUI = function(self)
	self:InitHeader()
	FrameTimer.New(function ()
		if not self.STATE_EnableOnce then
			return
		end

		if self.data and (self.data.isNpcPhone or self.data.OpenMessage) then
			self.bindData.bottomBarBtn_Contact:SetActive(false)
			self:OnClickBottomBarBtn(self.TabDefine.MessagePage)
		else
			self.bindData.bottomBarBtn_Contact:SetActive(true)
			self:OnClickBottomBarBtn(self.TabDefine.ContactPage)
		end

		self.bindData.tabRect:SetActiveFastest(true)
	end, 1):Start()
end

M.InitHeader = function(self)
	local isShowMyInfo = not gChatNpcsPhoneManager.isNpcsPhone
	local npcId = not isShowMyInfo and gChatNpcsPhoneManager.phoneCfg.Owner
	local currentNpcId = gChatManager:GetCurrentNpcId()

	if isShowMyInfo and currentNpcId == L50.Chat.ChatManager.PlayerSelf then
		isShowMyInfo = false
		npcId = currentNpcId
	end

	local headerWidget = self.bindData.header

	gChatUtils.SetHeader(self.bindData.header, true)

	local headerStore = gStoreManager:GetStoreGroup(headerWidget.Store):GetStoreByWidget(headerWidget)
	self.headerStore = headerStore

	if headerStore.showDropdownBtn then
		headerStore.showDropdownBtn.luaClick = self.CreateAction(self, self.OnShowDropdownBtnClick)
	end

	if headerStore.addFriendBtn then
		headerStore.addFriendBtn.luaClick = self.CreateAction(self, self.OnAddFriendBtnClick)
	end

	if headerStore.groupBtn then
		headerStore.groupBtn.luaClick = self.CreateAction(self, self.OnStartGroupChat)
	end

	if headerStore.closeBtn then
		headerStore.closeBtn.luaClick = self.CreateAction(self, self.CloseDropdown)
	end

	if headerStore.settingBtn then
		headerStore.settingBtn.luaClick = self.CreateAction(self, self.OnSettingBtnClick)
	end
end

M.CloseDropdown = function(self)
	self.headerStore.showDropdownCtrl = 0
end

M.OnShowDropdownBtnClick = function(self)
	self.headerStore.showDropdownCtrl = 1
end

M.OnAddFriendBtnClick = function(self)
	self:CloseDropdown()
	self.activity:ShowFragment(gChatConst.TabShowType.AddFriend)
end

M.OnStartGroupChat = function(self)
	self:CloseDropdown()
	self.activity:ShowFragment(gChatConst.TabShowType.CreateGroup)
end

M.OnPersonalPageBtnClick = function(self)
	gChatUtils.OpenPersonalPage()
end

M.OnSettingBtnClick = function(self)
	self.activity:ShowFragment(gChatConst.TabShowType.Setting)
end

M.OnGenerateTab = function(self, csIndex, tabInst)
	local store = gStoreManager:GetStoreGroup(tabInst.Store):GetStoreByWidget(tabInst)

	if csIndex ~= self.TabDefine.MessagePageCs then
		self.subStore.message = store
	else
		self.subStore.contact = store
	end

	store.list.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderSubChannelItem)
	store.list.luaSimpleClick = self.CreateAction(self, self.OnClickSubChannelItem)

	store.list.onGetTIndex = function(csIndex)
		return self.subChannelItems[csIndex + 1].tIndex
	end

	self.InitTopBar(self, csIndex, store)
end

M.OnRenderTab = function(self, csIndex, tabInst)
	local store = gStoreManager:GetStoreGroup(tabInst.Store):GetStoreByWidget(tabInst)

	if store then
		self.subStore.current = store
	end

	self.currentTabCsIndex = csIndex
	self.list = store.list

	self.RefreshTopBar(self, csIndex, store)
end

M.OnClickBottomBarBtn = function(self, index)
	self.bindData.tabRect.selectedIndex = index - 1

	for i, btn in ipairs(self.bottomBarBtnList) do
		btn:SetSelected(i ~= index)
	end

	self.bindData.header:SetActive(index ~= 1)
end

M.InitTopBar = function(self, csIndex, store)
	if store.topBarBtn_Friend then
		local data = {
			store = store,
			index = 1
		}
		store.topBarBtn_Friend.luaClick = self.CreateActionWithArgs(self, self.OnClickTopBarBtn, data)
		self.topBarBtn_Friend = store.topBarBtn_Friend
		local redKey = self.GetChatTopBarBtnFriendRedDotKey(self)
		self.topBarBtn_Friend.redKey = redKey
	end

	if store.topBarBtn_Channel then
		local data = {
			store = store,
			index = 2
		}
		store.topBarBtn_Channel.luaClick = self.CreateActionWithArgs(self, self.OnClickTopBarBtn, data)
	end

	if store.topBarBtn_Character then
		local data = {
			store = store,
			index = 3
		}
		store.topBarBtn_Character.luaClick = self.CreateActionWithArgs(self, self.OnClickTopBarBtn, data)
	end
end

M.OnClickTopBarBtn = function(self, data)
	local index = data.index
	data.store.status = index - 1
	local currentTabIndex = self.currentTabCsIndex + 1
	self.lastSelectTopChannelId[currentTabIndex] = index
	self.selectedTopBar = index

	if currentTabIndex ~= self.TabDefine.MessagePage then
		self.RefreshSubChannelList(self, index)

		return
	end

	self.selectedTopChannelId = self.TopBarIndex2TopChannelId[index]

	self.RefreshSubChannelList(self, self.selectedTopChannelId)
end

M.RefreshTopBar = function(self, csIndex, store)
	local index = csIndex + 1
	local data = {
		store = store
	}

	if index ~= self.TabDefine.ContactPage then
		self.topBarBtnList = {
			store.topBarBtn_Friend,
			store.topBarBtn_Channel,
			store.topBarBtn_Character
		}
		data.index = self.lastSelectTopChannelId[index] or 1

		self:OnClickTopBarBtn(data)
	elseif index ~= self.TabDefine.MessagePage then
		self.topBarBtnList = {
			store.topBarBtn_Character,
			store.topBarBtn_Friend
		}
		data.index = gChatTopChannel.Npc

		self.OnClickTopBarBtn(self, data)
	end
end

M.CreateSubChannelItem = function(self, topChannelId, subChannelId, isContactPage)
	local subChannel = self.GetSubChannel(self, topChannelId, subChannelId)

	if subChannel ~= nil and not isContactPage then
		return nil
	end

	subChannelId = gChatManager:TranslateSubChannelType(topChannelId, subChannelId)
	local message = subChannel and subChannel.lastMessage

	if gChatUtils.IsStoryChannel(topChannelId) and message ~= nil and not isContactPage then
		return nil
	end

	local timeStamp = message and message.timeStamp or 0
	local itemData = {
		["a\\x9f\\x8a\\x86Y"] = 0,
		id = self:IdToString(subChannelId),
		topChannelId = topChannelId,
		subChannelId = subChannelId,
		timeStamp = timeStamp
	}

	if message then
		itemData.content = message.GetPreviewText(message)
	elseif topChannelId ~= gChatTopChannel.Npc or topChannelId ~= gChatTopChannel.Friend then
		itemData.content = LTConfig.FriendsConfig.V4ChatMessageEmptyText
	else
		itemData.content = ""
	end

	return itemData
end

M.GetSubChannel = function(self, topChannelId, subChannelId)
	return gChatManager:GetChannel(topChannelId, subChannelId)
end

M.RefreshSubChannelList = function(self, topChannelId)
	local isContactPage = self.currentTabCsIndex ~= self.TabDefine.ContactPageCs

	if topChannelId ~= gChatTopChannel.FriendList then
		self.RefreshFriendList(self, isContactPage)
	elseif topChannelId ~= gChatTopChannel.Npc then
		self.RefreshStoryList(self)
	elseif topChannelId ~= gChatTopChannel.Friend then
		self.RefreshFriendMessage(self)
	elseif topChannelId ~= gChatTopChannel.Channels then
		self.RefreshGroupList(self)
	end
end

M.IsCurrentListShowFriendApplyBanner = function(self)
	if table.isNilOrEmpty(self.subChannelItems) then
		return false
	end

	local firstItem = self.subChannelItems[1]

	return firstItem and firstItem.tIndex ~= 1
end

M.SetSubChannelList = function(self)
	self.list:GoToIndex(0, true)
	self.list:SetSimpleList(#self.subChannelItems)
	self.list:SetNavSelectToTop()
	self.list:GoToIndex(0, true)
	self:OnSubChannelListChanged()
end

M.OnSubChannelListChanged = function(self)
	local isSubChannelEmpty = #self.subChannelItems ~= 0
	self.subStore.current.listEmptyCtrl = isSubChannelEmpty and 1 or 0
end

M.AddSubChannel = function(self, topChannelId, subChannelId)
	local item = self.CreateSubChannelItem(self, topChannelId, subChannelId)

	if item then
		table.insert(self.subChannelItems, item)
		self.SetSubChannelList(self)
	end
end

M.RemoveSubChannel = function(self, topChannelId, subChannelId)
	if self.subChannelItems ~= nil then
		return
	end

	local index = 0

	for i = 1, #self.subChannelItems do
		local view = self.subChannelItems[i]

		if view.topChannelId ~= topChannelId and view.subChannelId ~= subChannelId then
			index = i

			break
		end
	end

	if index <= 0 then
		table.remove(self.subChannelItems, index)
		self.list:SetSimpleList(#self.subChannelItems)
		self:OnSubChannelListChanged()
	end
end

M.OnRenderSubChannelItem = function(self, btn, index)
	local itemData = self.subChannelItems[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if itemData.tIndex ~= 1 then
		if itemData.topChannelId ~= gChatTopChannel.Group then
			store.count = gChatGroupManager:GetChatGroupInviteCount()
		else
			store.count = self.friendApplyCount
		end

		return
	end

	local redDotkey = self.GetSubChannelRedDotKey(self, itemData.subChannelId)

	if btn.redKey then
		btn.redKey = redDotkey
	end

	self.OnRenderItemCommon(self, btn, index, itemData, store)

	if self.selectedTopChannelId ~= gChatTopChannel.Friend and self.currentTabCsIndex == self.TabDefine.MessagePageCs then
		return
	end

	if self.currentTabCsIndex ~= self.TabDefine.MessagePageCs then
		store.message = itemData.content

		self.UpdateSubChannelUnread(self, itemData.topChannelId, itemData.subChannelId, nil, true)

		store.showTimeStamp = gChatUtils.IsOnlineChannel(itemData.topChannelId)
	else
		store.showTimeStamp = false

		gChatUtils.SetSignature(itemData.topChannelId, itemData.subChannelId, function (signature)
			store.message = signature
		end)
	end
end

M.OnRenderItemCommon = function(self, btn, index, itemData, store)
	gChatAvatarUtils:SetChannelAvatar(itemData.topChannelId, itemData.subChannelId, store.avatar)

	store.isSpecialCtrl = 0
	local renderItemFunction = self.RenderItemFunctions[itemData.topChannelId]

	if renderItemFunction then
		renderItemFunction(self, btn, index, itemData, store)
	else
		print_error("OnRenderItemCommon not found renderItemFunction, topChannelId:", itemData.topChannelId)
	end
end

M.OnClickSubChannelItem = function(self, btn, index)
	local itemData = self.subChannelItems[index + 1]

	if self.currentTabCsIndex ~= self.TabDefine.MessagePageCs then
		gChatManager:UpdateCurrentChannel(itemData.topChannelId, itemData.subChannelId)

		return
	end

	if itemData.topChannelId ~= gChatTopChannel.Npc or itemData.topChannelId ~= gChatTopChannel.NpcGroup then
		self.OnClickStorySubChannelItem(self, btn, itemData)
	elseif itemData.topChannelId ~= gChatTopChannel.Group then
		self.OnGroupItemBtnClick(self, btn, itemData)
	elseif self.selectedTopChannelId ~= gChatTopChannel.Friend then
		self.OnFriendItemBtnClick(self, btn, itemData)
	else
		self.OnClickOnlineSubChannelItem(self, btn, itemData)
	end
end

M.UpdateSubChannelUnread = function(self, topChannelId, subChannelId, count, force)
	if gChatNpcsPhoneManager.isNpcsPhone then
		return
	end

	count = count or self:GetSubChannelUnreadCount(topChannelId, subChannelId)

	SGUI.RedDotMgr.LuaSetRedDot(count >= 0, self:GetSubChannelRedDotKey(subChannelId))
	SGUI.RedDotMgr.LuaSetRedDot(count >= 0, self:GetChatTopBarBtnFriendRedDotKey())
end

M.GetSubChannelRedDotKey = function(self, subChannelId)
	return "ChatChannelItem:" .. self.IdToString(self, subChannelId)
end

M.GetChatTopBarBtnFriendRedDotKey = function(self)
	return "ChatTopBarBtnFriend"
end

M.IdToString = function(self, id)
	return ulong.check(id) and ulong.tostring(id) or tostring(id)
end

M.IsCurrentTopChannel = function(self, topChannelId)
	return self.selectedTopChannelId ~= topChannelId or gChatManager:IsAuxiliaryChannel(self.selectedTopChannelId, topChannelId)
end

M.GetSubChannelUnreadCount = function(self, topChannelId, subChannelId)
	local subChannel = gChatManager:GetChannel(topChannelId, subChannelId)

	return (subChannel or {}).unread or 0
end

M.RegisterMessageEventHandlers = function(self)
	local msgEvents = {
		[gEventConstants.UPDATE_UNREAD_MSG_TIPS] = self.CreateAction(self, self.OnUpdateSubChannelUnreadMsgTips),
		[gEventConstants.CHAT_ADD_CHANNEL] = self.CreateAction(self, self.OnChatAddChannel),
		[gEventConstants.CHAT_REMOVE_CHANNEL] = self.CreateAction(self, self.OnChatRemoveChannel),
		[gEventConstants.CHAT_UPDATE_CHATTER] = self.CreateAction(self, self.OnChatUpdateChatter),
		[gEventConstants.CHAT_LAST_MESSAGE_CHANGED] = self.CreateAction(self, self.OnChatLastMessage),
		[gEventConstants.CHAT_MESSAGE_CHANGED] = self.CreateAction(self, self.OnChatMessageChanged),
		[gEventConstants.UPDATE_FRIEND_APPLICATION_COUNT] = self.CreateAction(self, self.OnUpdateFriendApplicationCount),
		[gEventConstants.ADD_CHAT_FRIEND] = self.CreateAction(self, self.OnAddFriend),
		[gEventConstants.PLAYER_SIGN_CHANGED] = self.CreateAction(self, self.OnPlayerSignChanged),
		[gEventConstants.CHAT_REFRESH_GROUP_DATA] = self.CreateAction(self, self.OnRefreshGroupData)
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnUpdateSubChannelUnreadMsgTips = function(self, _, data)
	self.UpdateSubChannelUnread(self, data.topChannelId, data.subChannelId, data.count, true)
end

M.OnChatAddChannel = function(self, _, data)
	if self.IsCurrentTopChannel(self, data.topChannelId) then
		self.AddSubChannel(self, data.topChannelId, data.subChannelId)
	end
end

M.OnChatRemoveChannel = function(self, _, data)
	if self.IsCurrentTopChannel(self, data.topChannelId) then
		self.RemoveSubChannel(self, data.topChannelId, data.subChannelId)
	end
end

M.OnChatUpdateChatter = function(self, _, pid)
end

M.OnChatLastMessage = function(self, _, data)
	if not self.IsCurrentTopChannel(self, data.topChannelId) or self.subChannelItems ~= nil then
		return
	end

	local subChannelExist = false

	for i, item in ipairs(self.subChannelItems) do
		if item.topChannelId ~= data.topChannelId and ulong.equals(item.subChannelId, data.subChannelId) then
			self.subChannelItems[i] = self.CreateSubChannelItem(self, data.topChannelId, data.subChannelId)
			subChannelExist = true

			self.SetSubChannelList(self)

			break
		end
	end

	if not subChannelExist then
		self.AddSubChannel(self, data.topChannelId, data.subChannelId)
	end
end

M.OnChatMessageChanged = function(self, _, data)
	if self.IsCurrentTopChannel(self, data.topChannelId) and not data.msg then
		self.RemoveSubChannel(self, data.topChannelId, data.subChannelId)
	end
end

M.OnPlayerSignChanged = function(self, _, sign)
	self.bindData.signature = sign
end

M.OnRefreshGroupData = function(self)
	if self.IsCurrentTopChannel(self, gChatTopChannel.Channels) then
		self.RefreshGroupList(self)
	end
end
