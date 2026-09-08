-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NpcChat\NpcChatChannelPanelStore.lua
-- Decompiled from: 01954_NpcChatChannelPanelStore.lua_e1f2193cc572.luajit

C_NpcChatChannelPanelStore = DefClass("C_NpcChatChannelPanelStore", C_NpcChatChannelPanelStore, C_NpcChatFragmentStore)
GroupName2Class.NpcChatChannelPanelStore = C_NpcChatChannelPanelStore
local M = C_NpcChatChannelPanelStore

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
	self.RenderItemFunctions = {
		[gNpcChatConst.ChatTopChannel.Npc] = "OnRenderNpcItem",
		[gNpcChatConst.ChatTopChannel.NpcGroup] = "OnRenderNpcGroupItem"
	}
end

M.OnAwake = function(self)
	self.bindData.messageList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderSubChannelItem")
	self.bindData.messageList.luaSimpleClick = self.CreateAction(self, "OnClickSubChannelItem")
	self.bindData.messageList.onGetTIndex = self.CreateAction(self, "OnGetMessageListTIndex")

	self.RegisterMessageEventHandlers(self)
end

M.OnShow = function(self, _, data)
	self.data = data
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

M.CreateSubChannelItem = function(self, topChannelId, subChannelId, isContactPage)
	local subChannel = self.GetSubChannel(self, topChannelId, subChannelId)

	if subChannel ~= nil and not isContactPage then
		return nil
	end

	local message = nil
	local messages = gNpcChatUtils.GetNormalAndOtherToSelfMessages(subChannel)

	if not table.isNilOrEmpty(messages) then
		local segments = gNpcChatManager:GroupMessagesBySegment(messages)
		segments = gNpcChatManager:SortSegmentsByLastMessageTime(segments)

		if #segments <= 0 and #segments[#segments] <= 0 then
			local lastSegment = segments[#segments]
			message = lastSegment[#lastSegment]
		end
	end

	if message ~= nil and not isContactPage then
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
	elseif topChannelId ~= gNpcChatConst.ChatTopChannel.Npc then
		itemData.content = LTConfig.FriendsConfig.V4ChatMessageEmptyText
	else
		itemData.content = ""
	end

	return itemData
end

M.GetSubChannel = function(self, topChannelId, subChannelId)
	return gNpcChatManager:GetChannel(topChannelId, subChannelId)
end

M.RefreshSubChannelList = function(self, topChannelId)
	self.RefreshStoryList(self)
end

M.IsCurrentListShowFriendApplyBanner = function(self)
	if table.isNilOrEmpty(self.subChannelItems) then
		return false
	end

	local firstItem = self.subChannelItems[1]

	return firstItem and firstItem.tIndex ~= 1
end

M.SetSubChannelList = function(self)
	self.bindData.messageList:GoToIndex(0, true)
	self.bindData.messageList:SetSimpleList(#self.subChannelItems)
	self.bindData.messageList:SetNavSelectToTop()
	self.bindData.messageList:GoToIndex(0, true)
	self:OnSubChannelListChanged()
end

M.OnSubChannelListChanged = function(self)
	local isSubChannelEmpty = #self.subChannelItems ~= 0
	self.bindData.channelListCtrl = isSubChannelEmpty and 1 or 0
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
		self.bindData.messageList:SetSimpleList(#self.subChannelItems)
		self:OnSubChannelListChanged()
	end
end

M.OnEnable = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.RefreshSubChannelList(self)
end

M.OnRenderSubChannelItem = function(self, btn, index)
	local itemData = self.subChannelItems[index + 1]

	if not itemData then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if itemData.tIndex ~= 1 then
		store.count = self.friendApplyCount

		return
	end

	local redDotkey = self.GetSubChannelRedDotKey(self, itemData.subChannelId)

	if btn.redKey then
		btn.redKey = redDotkey
	end

	self.OnRenderItemCommon(self, btn, index, itemData, store)

	store.message = itemData.content

	self.UpdateSubChannelUnread(self, itemData.topChannelId, itemData.subChannelId, nil)
end

M.OnRenderItemCommon = function(self, btn, index, itemData, store)
	gNpcChatAvatarUtils:SetChannelAvatar(itemData.topChannelId, itemData.subChannelId, store.avatar)

	local renderItemFunctionName = self.RenderItemFunctions[itemData.topChannelId]

	if renderItemFunctionName and self[renderItemFunctionName] then
		self[renderItemFunctionName](self, btn, index, itemData, store)
	else
		print_error("@zhangzhiyuan06 OnRenderItemCommon not found renderItemFunction, topChannelId:", itemData.topChannelId)
	end
end

M.OnClickSubChannelItem = function(self, btn, index)
	local itemData = self.subChannelItems[index + 1]

	if not itemData then
		return
	end

	gNpcChatManager.currentNpcChatType = LTConfig.NPCChatConfig.ChatTypeType.Normal

	gNpcChatManager:UpdateCurrentChannel(itemData.topChannelId, itemData.subChannelId)
end

M.OnGetMessageListTIndex = function(self, index)
	local itemData = self.subChannelItems[index + 1]

	return itemData and itemData.tIndex or 0
end

M.UpdateSubChannelUnread = function(self, topChannelId, subChannelId)
	if gNpcChatNpcsPhoneManager.isNpcsPhone then
		return
	end

	local count = self:GetSubChannelUnreadCount(topChannelId, subChannelId)

	SGUI.RedDotMgr.LuaSetRedDot(count >= 0, self:GetSubChannelRedDotKey(subChannelId))
end

M.GetSubChannelRedDotKey = function(self, subChannelId)
	return "ChatChannelItem:" .. self.IdToString(self, subChannelId)
end

M.IdToString = function(self, id)
	return ulong.check(id) and ulong.tostring(id) or tostring(id)
end

M.IsCurrentTopChannel = function(self, topChannelId)
	return self.selectedTopChannelId ~= topChannelId or gNpcChatUtils.IsAuxiliaryChannel(self.selectedTopChannelId, topChannelId)
end

M.GetSubChannelUnreadCount = function(self, topChannelId, subChannelId)
	local subChannel = gNpcChatManager:GetChannel(topChannelId, subChannelId)

	return (subChannel or {}).unread or 0
end

M.RegisterMessageEventHandlers = function(self)
	local msgEvents = {
		[gEventConstants.UPDATE_UNREAD_MSG_TIPS] = self.CreateAction(self, "OnUpdateSubChannelUnreadMsgTips"),
		[gEventConstants.NPC_CHAT_ADD_CHANNEL] = self.CreateAction(self, "OnChatAddChannel"),
		[gEventConstants.NPC_CHAT_LAST_MESSAGE_CHANGED] = self.CreateAction(self, "OnChatLastMessage"),
		[gEventConstants.NPC_CHAT_MESSAGE_CHANGED] = self.CreateAction(self, "OnChatMessageChanged"),
		[gEventConstants.NPC_CHAT_GROUP_NAME_CHANGED] = self.CreateAction(self, "OnNpcChatGroupNameChanged")
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnUpdateSubChannelUnreadMsgTips = function(self, _, data)
	self.RefreshStoryList(self)
end

M.OnChatAddChannel = function(self, _, data)
	if self.IsCurrentTopChannel(self, data.topChannelId) then
		self.AddSubChannel(self, data.topChannelId, data.subChannelId)
	end
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

M.OnNpcChatGroupNameChanged = function(self, _, data)
	if not self.subChannelItems then
		return
	end

	for _, item in ipairs(self.subChannelItems) do
		if item.topChannelId ~= gNpcChatConst.ChatTopChannel.NpcGroup and ulong.equals(item.subChannelId, data.groupId) then
			self.SetSubChannelList(self)

			return
		end
	end
end

M.RefreshStoryList = function(self, isContactPage)
	local topChannelId = gNpcChatConst.ChatTopChannel.Npc
	local items = {}

	if isContactPage then
		local infoDict = gNpcInteracsUtils:GetInteractableNpcSet()

		for channelId, _ in pairs(infoDict) do
			local cfg = LTConfig.NpcCultivationConfig.GetConfig(channelId)

			if not gSpiritManager.CheckIsDefaultSpiritId(cfg.FightSpiritID) then
				table.insert(items, self.CreateSubChannelItem(self, topChannelId, channelId, true))
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
					table.insert(items, self.CreateSubChannelItem(self, iTopChannelId, channelId))
				end
			end
		end
	end

	gNpcChatUtils.SortSubChannelItems(items)

	self.subChannelItems = items

	self.SetSubChannelList(self)
end

M.OnRenderNpcItem = function(self, _, _, itemData, store)
	local npcTid = itemData.subChannelId

	if npcTid ~= gNpcChatConst.PlayerSelfIndex then
		local playerInfo = gPlayerManager.infoLogin.bindData
		store.name = playerInfo.name
		store.showOnline = true
		store.playerStateCtrl = 0

		return
	end

	local npcChatInfo = gDialogMainChatManager:GetNpcChatInfo(npcTid)

	if npcChatInfo ~= nil then
		return
	end

	store.name = npcChatInfo.GetName(npcChatInfo)
	store.showOnline = true
	store.playerStateCtrl = 0
end

M.OnRenderNpcGroupItem = function(self, _, _, itemData, store)
	local groupId = itemData.subChannelId
	store.name = gNpcChatUtils.GetNpcGroupDisplayName(groupId, false)
	store.showOnline = false
	store.playerStateCtrl = 0
end
