C_ChatChannelPanelStore = DefClass("C_ChatChannelPanelStore", C_ChatChannelPanelStore, C_AppFragmentStore)
GroupName2Class.ChatChannelPanelStore = C_ChatChannelPanelStore
local M = C_ChatChannelPanelStore

dofile("LX6/SGUI/StoreDefine/Chat/ChatChannelPanelStore_OnlinePart")
dofile("LX6/SGUI/StoreDefine/Chat/ChatChannelPanelStore_StoryPart")

function M:ctor()
	self.TabDefine = {
		ContactPageCs = 0,
		MessagePageCs = 1,
		MessagePage = 2,
		ContactPage = 1
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

function M:OnAwake()
	self.bindData.tabRect.OnGenerateTab = self:CreateAction(self.OnGenerateTab)
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.OnRenderTab)

	self.bindData.tabRect:SetActiveFastest(false)

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

function M:OnShow(_, data)
	self.data = data

	self:InitUI()
	self:InitFriend()
end

function M:OnEnable()
	self:InitFriend()
	FrameTimer.New(function ()
		self.bindData.signature = gChatUtils.GetMySignature()

		if self.currentTabCsIndex and self.currentTabCsIndex + 1 == self.TabDefine.MessagePageCs then
			self:RefreshSubChannelList(self.selectedTopBar)
		end

		if self.friendApplyCount then
			local redKey = self:GetChatTopBarBtnFriendRedDotKey()

			SGUI.RedDotMgr.LuaSetRedDot(self.friendApplyCount > 0, redKey)
		end
	end, 3):Start()
end

function M:OnDestroy()
	self:ClearMessageEvents()

	self.subChannelItems = nil
	self.friendApplyCount = nil
end

function M:HandleExit()
	self.activity:CloseThisActivity()

	return true
end

function M:InitUI()
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

function M:InitHeader()
	local isShowMyInfo = not gChatNpcsPhoneManager.isNpcsPhone
	local npcId = not isShowMyInfo and gChatNpcsPhoneManager.phoneCfg.Owner
	local currentNpcId = gChatManager:GetCurrentNpcId()

	if isShowMyInfo and currentNpcId ~= L50.Chat.ChatManager.PlayerSelf then
		isShowMyInfo = false
		npcId = currentNpcId
	end

	local headerWidget = self.bindData.header

	gChatUtils.SetHeader(self.bindData.header, true)

	local headerStore = gStoreManager:GetStoreGroup(headerWidget.Store):GetStoreByWidget(headerWidget)
	self.headerStore = headerStore

	if headerStore.showDropdownBtn then
		headerStore.showDropdownBtn.luaClick = self:CreateAction(self.OnShowDropdownBtnClick)
	end

	if headerStore.addFriendBtn then
		headerStore.addFriendBtn.luaClick = self:CreateAction(self.OnAddFriendBtnClick)
	end

	if headerStore.groupBtn then
		headerStore.groupBtn.luaClick = self:CreateAction(self.OnStartGroupChat)
	end

	if headerStore.closeBtn then
		headerStore.closeBtn.luaClick = self:CreateAction(self.CloseDropdown)
	end

	if headerStore.settingBtn then
		headerStore.settingBtn.luaClick = self:CreateAction(self.OnSettingBtnClick)
	end
end

function M:CloseDropdown()
	self.headerStore.showDropdownCtrl = 0
end

function M:OnShowDropdownBtnClick()
	self.headerStore.showDropdownCtrl = 1
end

function M:OnAddFriendBtnClick()
	self:CloseDropdown()
	self.activity:ShowFragment(gChatConst.TabShowType.AddFriend)
end

function M:OnStartGroupChat()
	self:CloseDropdown()
	self.activity:ShowFragment(gChatConst.TabShowType.CreateGroup)
end

function M:OnPersonalPageBtnClick()
	gChatUtils.OpenPersonalPage()
end

function M:OnSettingBtnClick()
	self.activity:ShowFragment(gChatConst.TabShowType.Setting)
end

function M:OnGenerateTab(csIndex, tabInst)
	local store = gStoreManager:GetStoreGroup(tabInst.Store):GetStoreByWidget(tabInst)

	if csIndex == self.TabDefine.MessagePageCs then
		self.subStore.message = store
	else
		self.subStore.contact = store
	end

	store.list.luaRenderItem = self:CreateAction(self.OnRenderSubChannelItem)
	store.list.luaClick = self:CreateAction(self.OnClickSubChannelItem)

	self:InitTopBar(csIndex, store)
end

function M:OnRenderTab(csIndex, tabInst)
	local store = gStoreManager:GetStoreGroup(tabInst.Store):GetStoreByWidget(tabInst)

	if store then
		self.subStore.current = store
	end

	self.currentTabCsIndex = csIndex
	self.list = store.list

	self:RefreshTopBar(csIndex, store)
end

function M:OnClickBottomBarBtn(index)
	self.bindData.tabRect.selectedIndex = index - 1

	for i, btn in ipairs(self.bottomBarBtnList) do
		btn:SetSelected(i == index)
	end

	self.bindData.header:SetActive(index == 1)
end

function M:InitTopBar(csIndex, store)
	if store.topBarBtn_Friend then
		local data = {
			store = store,
			index = 1
		}
		store.topBarBtn_Friend.luaClick = self:CreateActionWithArgs(self.OnClickTopBarBtn, data)
		self.topBarBtn_Friend = store.topBarBtn_Friend
		local redKey = self:GetChatTopBarBtnFriendRedDotKey()
		self.topBarBtn_Friend.redKey = redKey
	end

	if store.topBarBtn_Channel then
		local data = {
			store = store,
			index = 2
		}
		store.topBarBtn_Channel.luaClick = self:CreateActionWithArgs(self.OnClickTopBarBtn, data)
	end

	if store.topBarBtn_Character then
		local data = {
			store = store,
			index = 3
		}
		store.topBarBtn_Character.luaClick = self:CreateActionWithArgs(self.OnClickTopBarBtn, data)
	end
end

function M:OnClickTopBarBtn(data)
	local index = data.index
	data.store.status = index - 1
	local currentTabIndex = self.currentTabCsIndex + 1
	self.lastSelectTopChannelId[currentTabIndex] = index
	self.selectedTopBar = index

	if currentTabIndex == self.TabDefine.MessagePage then
		self:RefreshSubChannelList(index)

		return
	end

	self.selectedTopChannelId = self.TopBarIndex2TopChannelId[index]

	self:RefreshSubChannelList(self.selectedTopChannelId)
end

function M:RefreshTopBar(csIndex, store)
	local index = csIndex + 1
	local data = {
		store = store
	}

	if index == self.TabDefine.ContactPage then
		self.topBarBtnList = {
			store.topBarBtn_Friend,
			store.topBarBtn_Channel,
			store.topBarBtn_Character
		}
		data.index = self.lastSelectTopChannelId[index] or 1

		self:OnClickTopBarBtn(data)
	elseif index == self.TabDefine.MessagePage then
		self.topBarBtnList = {
			store.topBarBtn_Character,
			store.topBarBtn_Friend
		}
		data.index = gChatTopChannel.Npc

		self:OnClickTopBarBtn(data)
	end
end

function M:CreateSubChannelItem(topChannelId, subChannelId, isContactPage)
	local subChannel = self:GetSubChannel(topChannelId, subChannelId)

	if subChannel == nil and not isContactPage then
		return nil
	end

	subChannelId = gChatManager:TranslateSubChannelType(topChannelId, subChannelId)
	local message = subChannel and subChannel.lastMessage

	if gChatUtils.IsStoryChannel(topChannelId) and message == nil and not isContactPage then
		return nil
	end

	local timeStamp = message and message.timeStamp or 0
	local itemData = {
		tIndex = 0,
		id = self:IdToString(subChannelId),
		topChannelId = topChannelId,
		subChannelId = subChannelId,
		timeStamp = timeStamp
	}

	if message then
		itemData.content = message:GetPreviewText()
	elseif topChannelId == gChatTopChannel.Npc or topChannelId == gChatTopChannel.Friend then
		itemData.content = LTConfig.FriendsConfig.V4ChatMessageEmptyText
	else
		itemData.content = ""
	end

	return itemData
end

function M:GetSubChannel(topChannelId, subChannelId)
	return gChatManager:GetChannel(topChannelId, subChannelId)
end

function M:RefreshSubChannelList(topChannelId)
	local isContactPage = self.currentTabCsIndex == self.TabDefine.ContactPageCs

	if topChannelId == gChatTopChannel.FriendList then
		self:RefreshFriendList(isContactPage)
	elseif topChannelId == gChatTopChannel.Npc then
		self:RefreshStoryList()
	elseif topChannelId == gChatTopChannel.Friend then
		self:RefreshFriendMessage()
	elseif topChannelId == gChatTopChannel.Channels then
		self:RefreshGroupList()
	end
end

function M:IsCurrentListShowFriendApplyBanner()
	if table.isNilOrEmpty(self.subChannelItems) then
		return false
	end

	local firstItem = self.subChannelItems[1]

	return firstItem and firstItem.tIndex == 1
end

function M:SetSubChannelList()
	self.list:GoToIndex(0, true)
	self.list:SetList(self.subChannelItems)
	self.list:SetNavSelectToTop()
	self.list:GoToIndex(0, true)
	self:OnSubChannelListChanged()
end

function M:OnSubChannelListChanged()
	local isSubChannelEmpty = #self.subChannelItems == 0
	self.subStore.current.listEmptyCtrl = isSubChannelEmpty and 1 or 0
end

function M:AddSubChannel(topChannelId, subChannelId)
	local item = self:CreateSubChannelItem(topChannelId, subChannelId)

	if item then
		table.insert(self.subChannelItems, item)
		self:SetSubChannelList()
	end
end

function M:RemoveSubChannel(topChannelId, subChannelId)
	if self.subChannelItems == nil then
		return
	end

	local index = 0

	for i = 1, #self.subChannelItems do
		local view = self.subChannelItems[i]

		if view.topChannelId == topChannelId and view.subChannelId == subChannelId then
			index = i

			break
		end
	end

	if index > 0 then
		table.remove(self.subChannelItems, index)
		self.list:SetList(self.subChannelItems)
		self:OnSubChannelListChanged()
	end
end

function M:OnRenderSubChannelItem(btn, index, itemData)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if itemData.tIndex == 1 then
		if itemData.topChannelId == gChatTopChannel.Group then
			store.count = gChatGroupManager:GetChatGroupInviteCount()
		else
			store.count = self.friendApplyCount
		end

		return
	end

	local redDotkey = self:GetSubChannelRedDotKey(itemData.subChannelId)

	if btn.redKey then
		btn.redKey = redDotkey
	end

	self:OnRenderItemCommon(btn, index, itemData, store)

	if self.selectedTopChannelId == gChatTopChannel.Friend and self.currentTabCsIndex ~= self.TabDefine.MessagePageCs then
		return
	end

	if self.currentTabCsIndex == self.TabDefine.MessagePageCs then
		store.message = itemData.content

		self:UpdateSubChannelUnread(itemData.topChannelId, itemData.subChannelId, nil, true)

		store.showTimeStamp = gChatUtils.IsOnlineChannel(itemData.topChannelId)
	else
		store.showTimeStamp = false

		gChatUtils.SetSignature(itemData.topChannelId, itemData.subChannelId, function (signature)
			store.message = signature
		end)
	end
end

function M:OnRenderItemCommon(btn, index, itemData, store)
	gChatAvatarUtils:SetChannelAvatar(itemData.topChannelId, itemData.subChannelId, store.avatar)

	store.isSpecialCtrl = 0
	local renderItemFunction = self.RenderItemFunctions[itemData.topChannelId]

	if renderItemFunction then
		renderItemFunction(self, btn, index, itemData, store)
	else
		print_error("OnRenderItemCommon not found renderItemFunction, topChannelId:", itemData.topChannelId)
	end
end

function M:OnClickSubChannelItem(btn, itemData)
	if self.currentTabCsIndex == self.TabDefine.MessagePageCs then
		gChatManager:UpdateCurrentChannel(itemData.topChannelId, itemData.subChannelId)

		return
	end

	if itemData.topChannelId == gChatTopChannel.Npc or itemData.topChannelId == gChatTopChannel.NpcGroup then
		self:OnClickStorySubChannelItem(btn, itemData)
	elseif itemData.topChannelId == gChatTopChannel.Group then
		self:OnGroupItemBtnClick(btn, itemData)
	elseif self.selectedTopChannelId == gChatTopChannel.Friend then
		self:OnFriendItemBtnClick(btn, itemData)
	else
		self:OnClickOnlineSubChannelItem(btn, itemData)
	end
end

function M:UpdateSubChannelUnread(topChannelId, subChannelId, count, force)
	if gChatNpcsPhoneManager.isNpcsPhone then
		return
	end

	count = count or self:GetSubChannelUnreadCount(topChannelId, subChannelId)

	SGUI.RedDotMgr.LuaSetRedDot(count > 0, self:GetSubChannelRedDotKey(subChannelId))
	SGUI.RedDotMgr.LuaSetRedDot(count > 0, self:GetChatTopBarBtnFriendRedDotKey())
end

function M:GetSubChannelRedDotKey(subChannelId)
	return "ChatChannelItem:" .. self:IdToString(subChannelId)
end

function M:GetChatTopBarBtnFriendRedDotKey()
	return "ChatTopBarBtnFriend"
end

function M:IdToString(id)
	return ulong.check(id) and ulong.tostring(id) or tostring(id)
end

function M:IsCurrentTopChannel(topChannelId)
	return self.selectedTopChannelId == topChannelId or gChatManager:IsAuxiliaryChannel(self.selectedTopChannelId, topChannelId)
end

function M:GetSubChannelUnreadCount(topChannelId, subChannelId)
	local subChannel = gChatManager:GetChannel(topChannelId, subChannelId)

	return (subChannel or {}).unread or 0
end

function M:RegisterMessageEventHandlers()
	local msgEvents = {
		[gEventConstants.UPDATE_UNREAD_MSG_TIPS] = self:CreateAction(self.OnUpdateSubChannelUnreadMsgTips),
		[gEventConstants.CHAT_ADD_CHANNEL] = self:CreateAction(self.OnChatAddChannel),
		[gEventConstants.CHAT_REMOVE_CHANNEL] = self:CreateAction(self.OnChatRemoveChannel),
		[gEventConstants.CHAT_UPDATE_CHATTER] = self:CreateAction(self.OnChatUpdateChatter),
		[gEventConstants.CHAT_LAST_MESSAGE_CHANGED] = self:CreateAction(self.OnChatLastMessage),
		[gEventConstants.CHAT_MESSAGE_CHANGED] = self:CreateAction(self.OnChatMessageChanged),
		[gEventConstants.UPDATE_FRIEND_APPLICATION_COUNT] = self:CreateAction(self.OnUpdateFriendApplicationCount),
		[gEventConstants.ADD_CHAT_FRIEND] = self:CreateAction(self.OnAddFriend),
		[gEventConstants.PLAYER_SIGN_CHANGED] = self:CreateAction(self.OnPlayerSignChanged),
		[gEventConstants.CHAT_REFRESH_GROUP_DATA] = self:CreateAction(self.OnRefreshGroupData)
	}

	self:RegisterMessageEvents(msgEvents)
end

function M:OnUpdateSubChannelUnreadMsgTips(_, data)
	self:UpdateSubChannelUnread(data.topChannelId, data.subChannelId, data.count, true)
end

function M:OnChatAddChannel(_, data)
	if self:IsCurrentTopChannel(data.topChannelId) then
		self:AddSubChannel(data.topChannelId, data.subChannelId)
	end
end

function M:OnChatRemoveChannel(_, data)
	if self:IsCurrentTopChannel(data.topChannelId) then
		self:RemoveSubChannel(data.topChannelId, data.subChannelId)
	end
end

function M:OnChatUpdateChatter(_, pid)
	return
end

function M:OnChatLastMessage(_, data)
	if not self:IsCurrentTopChannel(data.topChannelId) or self.subChannelItems == nil then
		return
	end

	local subChannelExist = false

	for i, item in ipairs(self.subChannelItems) do
		if item.topChannelId == data.topChannelId and ulong.equals(item.subChannelId, data.subChannelId) then
			self.subChannelItems[i] = self:CreateSubChannelItem(data.topChannelId, data.subChannelId)
			subChannelExist = true

			self:SetSubChannelList()

			break
		end
	end

	if not subChannelExist then
		self:AddSubChannel(data.topChannelId, data.subChannelId)
	end
end

function M:OnChatMessageChanged(_, data)
	if self:IsCurrentTopChannel(data.topChannelId) and not data.msg then
		self:RemoveSubChannel(data.topChannelId, data.subChannelId)
	end
end

function M:OnPlayerSignChanged(_, sign)
	self.bindData.signature = sign
end

function M:OnRefreshGroupData()
	if self:IsCurrentTopChannel(gChatTopChannel.Channels) then
		self:RefreshGroupList()
	end
end
