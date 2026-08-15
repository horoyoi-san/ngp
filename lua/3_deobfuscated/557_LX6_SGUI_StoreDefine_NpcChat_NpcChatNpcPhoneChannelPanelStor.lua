C_NpcChatNpcPhoneChannelPanelStore = DefClass("C_NpcChatNpcPhoneChannelPanelStore", C_NpcChatNpcPhoneChannelPanelStore, C_NpcChatFragmentStore)
GroupName2Class.NpcChatNpcPhoneChannelPanelStore = C_NpcChatNpcPhoneChannelPanelStore
local M = C_NpcChatNpcPhoneChannelPanelStore

function M:ctor()
	self.RenderItemFunctions = {
		[gNpcChatConst.ChatTopChannel.Npc] = "OnRenderNpcItem",
		[gNpcChatConst.ChatTopChannel.NpcGroup] = "OnRenderNpcGroupItem"
	}
end

function M:OnRenderNpcItem(_, _, itemData, store)
	local npcTid = itemData.subChannelId
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

function M:OnAwake()
	self.bindData.messageList.luaSimpleRenderItem = self:CreateAction("OnRenderSubChannelItem")
	self.bindData.messageList.luaSimpleClick = self:CreateAction("OnClickSubChannelItem")
	self.bindData.messageList.onGetTIndex = self:CreateAction("OnGetMessageListTIndex")

	self:RegisterMessageEventHandlers()

	self.timeStampCounter = 0
	self.subChannelMessage = {}
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

function M:OnEnable()
	if not self.STATE_EnableOnce then
		return
	end

	self:RefreshSubChannelList()
end

function M:RefreshSubChannelList(topChannelId)
	local phoneCfg = gNpcChatNpcsPhoneManager.phoneCfg
	local dialogList = phoneCfg.Dialog
	local items = {}

	if gNpcChatNpcsPhoneManager.chatCfg.ChatType == LTConfig.NPCChatConfig.ChatTypeType.Dialog then
		local item = self:MakeChannelItemData(gNpcChatNpcsPhoneManager.chatCfg)

		table.insert(items, item)

		gNpcChatNpcsPhoneManager.subChannelId2DialogCfg[item.subChannelId] = dialogList[1]
	end

	local chat2PlayerSubChannelId = phoneCfg.Owner

	if gNpcChatUtils.HaveNormalTypeChat(topChannelId, chat2PlayerSubChannelId) then
		local itemData = {
			isChatToPlayer = true,
			tIndex = 0,
			topChannelId = gNpcChatConst.ChatTopChannel.Npc,
			subChannelId = chat2PlayerSubChannelId,
			chatType = LTConfig.NPCChatConfig.ChatTypeType.Normal,
			timeStamp = self.timeStampCounter
		}

		table.insert(items, itemData)

		local subChannel = gNpcChatManager:GetChannel(itemData.topChannelId, itemData.subChannelId)
		local message = subChannel.lastMessage

		if message then
			itemData.content = message:GetPreviewText()
		end

		self.timeStampCounter = self.timeStampCounter - 1
		gNpcChatNpcsPhoneManager.subChannelId2DialogCfg[chat2PlayerSubChannelId] = dialogList[#dialogList]
	end

	for i, firstChatId in ipairs(phoneCfg.ChatList) do
		local cfg = LTConfig.NPCChatConfig.GetConfig(firstChatId)
		local item = self:MakeChannelItemData(cfg)

		if table.find_if(items, function (v)
			return v.subChannelId == item.subChannelId
		end) == nil then
			table.insert(items, item)
			gNpcChatManager:GetOrAddSubChannel(item.topChannelId, item.subChannelId)

			gNpcChatNpcsPhoneManager.subChannelId2DialogCfg[item.subChannelId] = phoneCfg.Dialog[i]
		elseif cfg.ChatType == LTConfig.NPCChatConfig.ChatTypeType.Fake then
			print_error("@liulijun04 Fake 类型消息（ID：" .. cfg.Id .. "）的发言者已经在消息列表里了，或是和自己对话，请策划检查一下配表。")
		end
	end

	self.subChannelItems = items

	self:SetSubChannelList()
end

function M:CreateSubChannelItem(topChannelId, subChannelId, isContactPage)
	local subChannel = self:GetSubChannel(topChannelId, subChannelId)

	if subChannel == nil and not isContactPage then
		return nil
	end

	local message = subChannel and subChannel.lastMessage

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
	elseif topChannelId == gNpcChatConst.ChatTopChannel.Npc or topChannelId == gNpcChatConst.ChatTopChannel.Friend then
		itemData.content = LTConfig.FriendsConfig.V4ChatMessageEmptyText
	else
		itemData.content = ""
	end

	return itemData
end

function M:SetSubChannelList()
	self.bindData.messageList:GoToIndex(0, true)
	self.bindData.messageList:SetSimpleList(#self.subChannelItems)
	self.bindData.messageList:SetNavSelectToTop()
	self.bindData.messageList:GoToIndex(0, true)
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

function M:OnRenderItemCommon(btn, index, itemData, store)
	gNpcChatAvatarUtils:SetChannelAvatar(itemData.topChannelId, itemData.subChannelId, store.avatar)

	local renderItemFunctionName = self.RenderItemFunctions[itemData.topChannelId]

	if renderItemFunctionName and self[renderItemFunctionName] then
		self[renderItemFunctionName](self, btn, index, itemData, store)
	else
		print_error("@liulijun04 OnRenderItemCommon not found renderItemFunction, topChannelId:", itemData.topChannelId)
	end
end

function M:UpdateSubChannelUnread(topChannelId, subChannelId, count, force)
	if gNpcChatNpcsPhoneManager.isNpcsPhone then
		return
	end

	count = count or self:GetSubChannelUnreadCount(topChannelId, subChannelId)

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
	self:UpdateSubChannelUnread(data.topChannelId, data.subChannelId, data.count, true)
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

function M:MakeChannelItemData(cfg)
	local msg = gNpcChatNpcsPhoneManager:GetLastMessage(cfg)
	local item = {
		tIndex = 0,
		topChannelId = msg.topChannelId,
		subChannelId = msg.subChannelId,
		timeStamp = self.timeStampCounter,
		cfg = cfg,
		content = msg:GetPreviewText(),
		chatType = cfg.ChatType
	}
	self.timeStampCounter = self.timeStampCounter - 1
	self.subChannelMessage[item.subChannelId] = msg

	return item
end

function M:GetSubChannel(topChannelId, subChannelId)
	if subChannelId == gNpcChatNpcsPhoneManager.phoneCfg.Owner or subChannelId == gNpcChatNpcsPhoneManager.subChannelId then
		return gNpcChatManager:GetChannel(topChannelId, subChannelId)
	end

	local msg = self.subChannelMessage[subChannelId]

	return {
		lastMessage = msg
	}
end

function M:OnClickSubChannelItem(btn, index)
	local itemData = self.subChannelItems[index + 1]

	if not itemData then
		return
	end

	gNpcChatManager.currentNpcChatType = itemData.chatType
	gNpcChatNpcsPhoneManager.currentChatCfg = itemData.cfg

	gNpcChatManager:UpdateCurrentChannel(itemData.topChannelId, itemData.subChannelId)
end

function M:OnRenderSubChannelItem(btn, index)
	local itemData = self.subChannelItems[index + 1]

	if not itemData then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local redDotkey = self:GetSubChannelRedDotKey(itemData.subChannelId)

	if btn.redKey then
		btn.redKey = redDotkey
	end

	self:OnRenderItemCommon(btn, index, itemData, store)

	store.message = itemData.content

	self:UpdateSubChannelUnread(itemData.topChannelId, itemData.subChannelId, nil, true)
end

function M:OnGetMessageListTIndex(index)
	local itemData = self.subChannelItems[index + 1]

	return itemData and itemData.tIndex or 0
end
