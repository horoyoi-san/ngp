-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NpcChat\NpcChatNpcPhoneChannelPanelStore.lua
-- Decompiled from: 01962_NpcChatNpcPhoneChannelPanelStore.lua_32730dbc2ac2.luajit

C_NpcChatNpcPhoneChannelPanelStore = DefClass("C_NpcChatNpcPhoneChannelPanelStore", C_NpcChatNpcPhoneChannelPanelStore, C_NpcChatFragmentStore)
GroupName2Class.NpcChatNpcPhoneChannelPanelStore = C_NpcChatNpcPhoneChannelPanelStore
local M = C_NpcChatNpcPhoneChannelPanelStore

M.ctor = function(self)
	self.RenderItemFunctions = {
		[gNpcChatConst.ChatTopChannel.Npc] = "OnRenderNpcItem",
		[gNpcChatConst.ChatTopChannel.NpcGroup] = "OnRenderNpcGroupItem"
	}
end

M.OnRenderNpcItem = function(self, _, _, itemData, store)
	local npcTid = itemData.subChannelId
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

M.OnAwake = function(self)
	self.bindData.messageList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderSubChannelItem")
	self.bindData.messageList.luaSimpleClick = self.CreateAction(self, "OnClickSubChannelItem")
	self.bindData.messageList.onGetTIndex = self.CreateAction(self, "OnGetMessageListTIndex")

	self.RegisterMessageEventHandlers(self)

	self.timeStampCounter = 0
	self.subChannelMessage = {}
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

M.OnEnable = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.RefreshSubChannelList(self)
end

M.RefreshSubChannelList = function(self, topChannelId)
	local phoneCfg = gNpcChatNpcsPhoneManager.phoneCfg
	local dialogList = phoneCfg.Dialog
	local items = {}

	if gNpcChatNpcsPhoneManager.chatCfg.ChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Dialog then
		local item = self.MakeChannelItemData(self, gNpcChatNpcsPhoneManager.chatCfg)

		table.insert(items, item)

		gNpcChatNpcsPhoneManager.subChannelId2DialogCfg[item.subChannelId] = dialogList[1]
	end

	local chat2PlayerSubChannelId = phoneCfg.Owner

	if gNpcChatUtils.HaveNormalTypeChat(topChannelId, chat2PlayerSubChannelId) then
		local itemData = {
			["\\xee\\x892\\xe4\\xd2ڄ\\xec\\x9b%:"] = true,
			["a\\x9f\\x8a\\x86Y"] = 0,
			topChannelId = gNpcChatConst.ChatTopChannel.Npc,
			subChannelId = chat2PlayerSubChannelId,
			chatType = LTConfig.NPCChatConfig.ChatTypeType.Normal,
			timeStamp = self.timeStampCounter
		}

		table.insert(items, itemData)

		local subChannel = gNpcChatManager:GetChannel(itemData.topChannelId, itemData.subChannelId)
		local message = subChannel.lastMessage

		if message then
			itemData.content = message.GetPreviewText(message)
		end

		self.timeStampCounter = self.timeStampCounter - 1
		gNpcChatNpcsPhoneManager.subChannelId2DialogCfg[chat2PlayerSubChannelId] = dialogList[#dialogList]
	end

	for i, firstChatId in ipairs(phoneCfg.ChatList) do
		local cfg = LTConfig.NPCChatConfig.GetConfig(firstChatId)
		local item = self.MakeChannelItemData(self, cfg)

		if table.find_if(items, function (v)
			return v.subChannelId ~= item.subChannelId
		end) ~= nil then
			table.insert(items, item)
			gNpcChatManager:GetOrAddSubChannel(item.topChannelId, item.subChannelId)

			gNpcChatNpcsPhoneManager.subChannelId2DialogCfg[item.subChannelId] = phoneCfg.Dialog[i]
		elseif cfg.ChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Fake then
			print_error("@zhangzhiyuan06 Fake 类型消息（ID：" .. cfg.Id .. "）的发言者已经在消息列表里了，或是和自己对话，请策划检查一下配表。")
		end
	end

	self.subChannelItems = items

	self.SetSubChannelList(self)
end

M.CreateSubChannelItem = function(self, topChannelId, subChannelId, isContactPage)
	local subChannel = self.GetSubChannel(self, topChannelId, subChannelId)

	if subChannel ~= nil and not isContactPage then
		return nil
	end

	local message = subChannel and subChannel.lastMessage

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
	elseif topChannelId ~= gNpcChatConst.ChatTopChannel.Npc or topChannelId ~= gNpcChatConst.ChatTopChannel.Friend then
		itemData.content = LTConfig.FriendsConfig.V4ChatMessageEmptyText
	else
		itemData.content = ""
	end

	return itemData
end

M.SetSubChannelList = function(self)
	self.bindData.messageList:GoToIndex(0, true)
	self.bindData.messageList:SetSimpleList(#self.subChannelItems)
	self.bindData.messageList:SetNavSelectToTop()
	self.bindData.messageList:GoToIndex(0, true)
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

M.OnRenderItemCommon = function(self, btn, index, itemData, store)
	gNpcChatAvatarUtils:SetChannelAvatar(itemData.topChannelId, itemData.subChannelId, store.avatar)

	local renderItemFunctionName = self.RenderItemFunctions[itemData.topChannelId]

	if renderItemFunctionName and self[renderItemFunctionName] then
		self[renderItemFunctionName](self, btn, index, itemData, store)
	else
		print_error("@zhangzhiyuan06 OnRenderItemCommon not found renderItemFunction, topChannelId:", itemData.topChannelId)
	end
end

M.UpdateSubChannelUnread = function(self, topChannelId, subChannelId, count, force)
	if gNpcChatNpcsPhoneManager.isNpcsPhone then
		return
	end

	count = count or self:GetSubChannelUnreadCount(topChannelId, subChannelId)

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
	self.UpdateSubChannelUnread(self, data.topChannelId, data.subChannelId, data.count, true)
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

M.MakeChannelItemData = function(self, cfg)
	local msg = gNpcChatNpcsPhoneManager:GetLastMessage(cfg)
	local item = {
		["a\\x9f\\x8a\\x86Y"] = 0,
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

M.GetSubChannel = function(self, topChannelId, subChannelId)
	if subChannelId ~= gNpcChatNpcsPhoneManager.phoneCfg.Owner or subChannelId ~= gNpcChatNpcsPhoneManager.subChannelId then
		return gNpcChatManager:GetChannel(topChannelId, subChannelId)
	end

	local msg = self.subChannelMessage[subChannelId]

	return {
		lastMessage = msg
	}
end

M.OnClickSubChannelItem = function(self, btn, index)
	local itemData = self.subChannelItems[index + 1]

	if not itemData then
		return
	end

	gNpcChatManager.currentNpcChatType = itemData.chatType
	gNpcChatNpcsPhoneManager.currentChatCfg = itemData.cfg

	gNpcChatManager:UpdateCurrentChannel(itemData.topChannelId, itemData.subChannelId)
end

M.OnRenderSubChannelItem = function(self, btn, index)
	local itemData = self.subChannelItems[index + 1]

	if not itemData then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local redDotkey = self:GetSubChannelRedDotKey(itemData.subChannelId)

	if btn.redKey then
		btn.redKey = redDotkey
	end

	self.OnRenderItemCommon(self, btn, index, itemData, store)

	store.message = itemData.content

	self.UpdateSubChannelUnread(self, itemData.topChannelId, itemData.subChannelId, nil, true)
end

M.OnGetMessageListTIndex = function(self, index)
	local itemData = self.subChannelItems[index + 1]

	return itemData and itemData.tIndex or 0
end
