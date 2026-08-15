C_NpcChatChannelPanelStore = DefClass("C_NpcChatChannelPanelStore", C_NpcChatChannelPanelStore, C_NpcChatFragmentStore)
GroupName2Class.NpcChatChannelPanelStore = C_NpcChatChannelPanelStore
local M = C_NpcChatChannelPanelStore

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
	self.RenderItemFunctions = {
		[gNpcChatConst.ChatTopChannel.Npc] = "OnRenderNpcItem",
		[gNpcChatConst.ChatTopChannel.NpcGroup] = "OnRenderNpcGroupItem"
	}
end

function M:OnAwake()
	self.bindData.messageList.luaSimpleRenderItem = self:CreateAction("OnRenderSubChannelItem")
	self.bindData.messageList.luaSimpleClick = self:CreateAction("OnClickSubChannelItem")
	self.bindData.messageList.onGetTIndex = self:CreateAction("OnGetMessageListTIndex")

	self:RegisterMessageEventHandlers()
end

function M:OnShow(_, data)
	self.data = data
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

function M:CreateSubChannelItem(topChannelId, subChannelId, isContactPage)
	local subChannel = self:GetSubChannel(topChannelId, subChannelId)

	if subChannel == nil and not isContactPage then
		return nil
	end

	local message = nil
	local messages = gNpcChatUtils.GetNormalAndOtherToSelfMessages(subChannel)

	if not table.isNilOrEmpty(messages) then
		local segments = gNpcChatManager:GroupMessagesBySegment(messages)
		segments = gNpcChatManager:SortSegmentsByLastMessageTime(segments)

		if #segments > 0 and #segments[#segments] > 0 then
			local lastSegment = segments[#segments]
			message = lastSegment[#lastSegment]
		end
	end

	if message == nil and not isContactPage then
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
	elseif topChannelId == gNpcChatConst.ChatTopChannel.Npc then
		itemData.content = LTConfig.FriendsConfig.V4ChatMessageEmptyText
	else
		itemData.content = ""
	end

	return itemData
end

function M:GetSubChannel(topChannelId, subChannelId)
	return gNpcChatManager:GetChannel(topChannelId, subChannelId)
end

function M:RefreshSubChannelList(topChannelId)
	self:RefreshStoryList()
end

function M:IsCurrentListShowFriendApplyBanner()
	if table.isNilOrEmpty(self.subChannelItems) then
		return false
	end

	local firstItem = self.subChannelItems[1]

	return firstItem and firstItem.tIndex == 1
end

function M:SetSubChannelList()
	self.bindData.messageList:GoToIndex(0, true)
	self.bindData.messageList:SetSimpleList(#self.subChannelItems)
	self.bindData.messageList:SetNavSelectToTop()
	self.bindData.messageList:GoToIndex(0, true)
	self:OnSubChannelListChanged()
end

function M:OnSubChannelListChanged()
	local isSubChannelEmpty = #self.subChannelItems == 0
	self.bindData.channelListCtrl = isSubChannelEmpty and 1 or 0
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
		self.bindData.messageList:SetSimpleList(#self.subChannelItems)
		self:OnSubChannelListChanged()
	end
end

function M:OnEnable()
	if not self.STATE_EnableOnce then
		return
	end

	self:RefreshSubChannelList()
end

function M:OnRenderSubChannelItem(btn, index)
	local itemData = self.subChannelItems[index + 1]

	if not itemData then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if itemData.tIndex == 1 then
		store.count = self.friendApplyCount

		return
	end

	local redDotkey = self:GetSubChannelRedDotKey(itemData.subChannelId)

	if btn.redKey then
		btn.redKey = redDotkey
	end

	self:OnRenderItemCommon(btn, index, itemData, store)

	store.message = itemData.content

	self:UpdateSubChannelUnread(itemData.topChannelId, itemData.subChannelId, nil)
end

function M:OnRenderItemCommon(btn, index, itemData, store)
	gNpcChatAvatarUtils:SetChannelAvatar(itemData.topChannelId, itemData.subChannelId, store.avatar)

	local renderItemFunctionName = self.RenderItemFunctions[itemData.topChannelId]

	if renderItemFunctionName and self[renderItemFunctionName] then
		self[renderItemFunctionName](self, btn, index, itemData, store)
	else
		print_error("@liulijun04 OnRenderItemCommon not found renderItemFunction, topChannelId:", itemData.topChannelId)
	end
end

function M:OnClickSubChannelItem(btn, index)
	local itemData = self.subChannelItems[index + 1]

	if not itemData then
		return
	end

	gNpcChatManager.currentNpcChatType = LTConfig.NPCChatConfig.ChatTypeType.Normal

	gNpcChatManager:UpdateCurrentChannel(itemData.topChannelId, itemData.subChannelId)
end

function M:OnGetMessageListTIndex(index)
	local itemData = self.subChannelItems[index + 1]

	return itemData and itemData.tIndex or 0
end

function M:UpdateSubChannelUnread(topChannelId, subChannelId)
	if gNpcChatNpcsPhoneManager.isNpcsPhone then
		return
	end

	local count = self:GetSubChannelUnreadCount(topChannelId, subChannelId)

	SGUI.RedDotMgr.LuaSetRedDot(count > 0, self:GetSubChannelRedDotKey(subChannelId))
end

function M:GetSubChannelRedDotKey(subChannelId)
	return "ChatChannelItem:" .. self:IdToString(subChannelId)
end

function M:IdToString(id)
	return ulong.check(id) and ulong.tostring(id) or tostring(id)
end

function M:IsCurrentTopChannel(topChannelId)
	return self.selectedTopChannelId == topChannelId or gNpcChatUtils.IsAuxiliaryChannel(self.selectedTopChannelId, topChannelId)
end

function M:GetSubChannelUnreadCount(topChannelId, subChannelId)
	local subChannel = gNpcChatManager:GetChannel(topChannelId, subChannelId)

	return (subChannel or {}).unread or 0
end

function M:RegisterMessageEventHandlers()
	local msgEvents = {
		[gEventConstants.UPDATE_UNREAD_MSG_TIPS] = self:CreateAction("OnUpdateSubChannelUnreadMsgTips"),
		[gEventConstants.NPC_CHAT_ADD_CHANNEL] = self:CreateAction("OnChatAddChannel"),
		[gEventConstants.NPC_CHAT_LAST_MESSAGE_CHANGED] = self:CreateAction("OnChatLastMessage"),
		[gEventConstants.NPC_CHAT_MESSAGE_CHANGED] = self:CreateAction("OnChatMessageChanged")
	}

	self:RegisterMessageEvents(msgEvents)
end

function M:OnUpdateSubChannelUnreadMsgTips(_, data)
	self:RefreshStoryList()
end

function M:OnChatAddChannel(_, data)
	if self:IsCurrentTopChannel(data.topChannelId) then
		self:AddSubChannel(data.topChannelId, data.subChannelId)
	end
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

function M:RefreshStoryList(isContactPage)
	local topChannelId = gNpcChatConst.ChatTopChannel.Npc
	local items = {}

	if isContactPage then
		local infoDict = gNpcInteracsUtils:GetInteractableNpcSet()

		for channelId, _ in pairs(infoDict) do
			local cfg = LTConfig.NpcCultivationConfig.GetConfig(channelId)

			if not gSpiritManager.CheckIsDefaultSpiritId(cfg.FightSpiritID) then
				table.insert(items, self:CreateSubChannelItem(topChannelId, channelId, true))
			end
		end
	else
		local baseTopChannel = gNpcChatManager:GetChannel(gNpcChatConst.ChatTopChannel.Npc)
		local topChannels = {
			[topChannelId] = baseTopChannel.subChannels,
			[gNpcChatConst.ChatTopChannel.NpcGroup] = gNpcChatManager:GetChannel(gNpcChatConst.ChatTopChannel.NpcGroup).subChannels
		}

		for iTopChannelId, topChannel in pairs(topChannels) do
			for channelId, channelInfo in pairs(topChannel) do
				if gNpcChatUtils.HaveNormalTypeChat(iTopChannelId, channelId) then
					table.insert(items, self:CreateSubChannelItem(iTopChannelId, channelId))
				end
			end
		end
	end

	gNpcChatUtils.SortSubChannelItems(items)

	self.subChannelItems = items

	self:SetSubChannelList()
end

function M:OnRenderNpcItem(_, _, itemData, store)
	local npcTid = itemData.subChannelId

	if npcTid == gNpcChatConst.PlayerSelfIndex then
		local playerInfo = gPlayerManager.infoLogin.bindData
		store.name = playerInfo.name
		store.showOnline = true
		store.playerStateCtrl = 0

		return
	end

	local npcChatInfo = gDialogMainChatManager:GetNpcChatInfo(npcTid)

	if npcChatInfo == nil then
		return
	end

	store.name = npcChatInfo:GetName()
	store.showOnline = true
	store.playerStateCtrl = 0
end

function M:OnRenderNpcGroupItem(_, _, itemData, store)
	local groupId = itemData.subChannelId
	local cfg = LTConfig.NPCChatGroupConfig.GetConfig(groupId)
	store.name = cfg.GroupName
	store.showOnline = false
	store.playerStateCtrl = 0
end
