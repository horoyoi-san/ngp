-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\NpcPhoneChannelPanelStore.lua
-- Decompiled from: 02105_NpcPhoneChannelPanelStore.lua_c50526230cb0.luajit

C_NpcPhoneChannelPanelStore = DefClass("C_NpcPhoneChannelPanelStore", C_NpcPhoneChannelPanelStore, C_ChatChannelPanelStore)
GroupName2Class.NpcPhoneChannelPanelStore = C_NpcPhoneChannelPanelStore
local M = C_NpcPhoneChannelPanelStore

M.OnAwake = function(self)
	M.base.OnAwake(self)

	self.timeStampCounter = 0
	self.subChannelMessage = {}
end

M.InitFriend = function(self)
end

M.RefreshSubChannelList = function(self, topChannelId)
	local phoneCfg = gChatNpcsPhoneManager.phoneCfg
	local dialogList = phoneCfg.Dialog
	local items = {}

	if gChatNpcsPhoneManager.chatCfg.ChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Dialog then
		local item = self.MakeChannelItemData(self, gChatNpcsPhoneManager.chatCfg)

		table.insert(items, item)

		gChatNpcsPhoneManager.subChannelId2DialogCfg[item.subChannelId] = dialogList[1]
	end

	local chat2PlayerSubChannelId = phoneCfg.Owner

	if gChatManager:HaveNormalTypeChat(topChannelId, chat2PlayerSubChannelId) then
		local itemData = {
			["\\xee\\x892\\xe4\\xd2ڄ\\xec\\x9b%:"] = true,
			["a\\x9f\\x8a\\x86Y"] = 0,
			topChannelId = gChatTopChannel.Npc,
			subChannelId = chat2PlayerSubChannelId,
			chatType = LTConfig.NPCChatConfig.ChatTypeType.Normal,
			timeStamp = self.timeStampCounter
		}

		table.insert(items, itemData)

		local subChannel = gChatManager:GetChannel(itemData.topChannelId, itemData.subChannelId)
		local message = subChannel.lastMessage

		if message then
			itemData.content = message.GetPreviewText(message)
		end

		self.timeStampCounter = self.timeStampCounter - 1
		gChatNpcsPhoneManager.subChannelId2DialogCfg[chat2PlayerSubChannelId] = dialogList[#dialogList]
	end

	for i, firstChatId in ipairs(phoneCfg.ChatList) do
		local cfg = LTConfig.NPCChatConfig.GetConfig(firstChatId)
		local item = self.MakeChannelItemData(self, cfg)

		if table.find_if(items, function (v)
			return v.subChannelId ~= item.subChannelId
		end) ~= nil then
			table.insert(items, item)
			gChatManager:GetOrAddSubChannel(item.topChannelId, item.subChannelId)

			gChatNpcsPhoneManager.subChannelId2DialogCfg[item.subChannelId] = phoneCfg.Dialog[i]
		elseif cfg.ChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Fake then
			print_error("@liulijun04 Fake 类型消息（ID：" .. cfg.Id .. "）的发言者已经在消息列表里了，或是和自己对话，请策划检查一下配表。")
		end
	end

	self.subChannelItems = items

	self.SetSubChannelList(self)
end

M.MakeChannelItemData = function(self, cfg)
	local msg = gChatNpcsPhoneManager:GetLastMessage(cfg)
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
	if subChannelId ~= gChatNpcsPhoneManager.phoneCfg.Owner or subChannelId ~= gChatNpcsPhoneManager.subChannelId then
		return M.base.GetSubChannel(self, topChannelId, subChannelId)
	end

	local msg = self.subChannelMessage[subChannelId]

	return {
		lastMessage = msg
	}
end

M.OnClickSubChannelItem = function(self, btn, itemData)
	gChatManager.currentNpcChatType = itemData.chatType
	gChatNpcsPhoneManager.currentChatCfg = itemData.cfg

	M.base.OnClickSubChannelItem(self, btn, itemData)
end

M.OnRenderSubChannelItem = function(self, btn, index, itemData)
	M.base.OnRenderSubChannelItem(self, btn, index, itemData)

	if itemData.isChatToPlayer then
		local store = gStoreManager:GetStoreGroup("ChatBaseCardTemplateStore"):GetStoreByWidget(btn)
		store.name = gPlayerManager.infoLogin.bindData.name
		local sender = {
			pid = gPlayerManager.infoLogin.bindData.pid
		}

		gChatAvatarUtils:SetSingleAvatar(sender, store.avatar)
	end
end

M.OnClickBottomBarBtn = function(self, index)
	if index ~= self.TabDefine.MessagePage then
		M.base.OnClickBottomBarBtn(self, index)
	else
		gChatNpcsPhoneManager:NoticeIsNpcsPhone()
	end
end

M.OnClickTopBarBtn = function(self, index)
	if self.TopBarIndex2TopChannelId[index] ~= gChatTopChannel.Npc then
		M.base.OnClickTopBarBtn(self, index)
	else
		gChatNpcsPhoneManager:NoticeIsNpcsPhone()
	end
end
