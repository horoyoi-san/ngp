-- Original chunk: @Lua\LuaFiles\LX6\Manager\NpcChat\NpcChatManager_Channel.lua
-- Decompiled from: 00303_NpcChatManager_Channel.lua_849dfc4a067f.luajit

local ChatType = LTConfig.NPCChatConfig.ChatTypeType
NpcChannelInfo = DefClass("NpcChannelInfo", NpcChannelInfo)

NpcChannelInfo.ctor = function(self)
	self.topChannelId = 0
	self.subChannelId = 0
	self.messages = {}
	self.messageDict = {}
	self.unread = 0
	self.subChannels = {}
	self.lastMessage = nil
end

local M = C_NpcChatManager

M.Init_Channel = function(self)
	self.clientChannels = {}
end

M.GetChannel = function(self, topChannelId, subChannelId)
	local topChannel = self.clientChannels[topChannelId]

	if not topChannel then
		return nil
	end

	if not subChannelId then
		return topChannel
	end

	return topChannel.subChannels and topChannel.subChannels[subChannelId]
end

M.GetOrAddSubChannel = function(self, topChannelId, subChannelId)
	local channel = self.GetChannel(self, topChannelId, subChannelId)

	if not channel then
		return self.InsertSubChannel(self, topChannelId, subChannelId, NpcChannelInfo.new())
	end

	return channel
end

M.InsertSubChannel = function(self, topChannelId, subChannelId, channelInfo)
	local topChannel = self.GetChannel(self, topChannelId)

	if not topChannel or subChannelId ~= 0 then
		print_error("InsertSubChannel Error 聊天没有频道:", topChannelId)

		return nil
	end

	if not topChannel.subChannels then
		topChannel.subChannels = {}
	end

	topChannel.subChannels[subChannelId] = channelInfo
	channelInfo.topChannelId = topChannelId
	channelInfo.subChannelId = subChannelId
	local param = {
		[topChannelId] = topChannelId,
		[subChannelId] = subChannelId
	}

	gMessageManager:SendMessage(gEventConstants.NPC_CHAT_ADD_CHANNEL, param)

	return channelInfo
end

M.ResetMessageOfChannelInfo = function(self, topChannelId, subChannelId)
	local channel = self.GetChannel(self, topChannelId, subChannelId)

	if not channel then
		return
	end

	if channel.messages then
		for index, msg in ipairs(channel.messages) do
			channel.messages[index] = nil
		end
	end

	channel.messages = {}
	channel.messageDict = {}
	channel.lastMessage = nil

	self:SetUnreadCount(topChannelId, subChannelId, 0)

	local param = {
		topChannelId = topChannelId,
		subChannelId = subChannelId
	}

	gMessageManager:SendMessage(gEventConstants.NPC_CHAT_MESSAGE_CHANGED, param)
	gMessageManager:SendMessage(gEventConstants.NPC_CHAT_CLEAR_CHANNEL_MESSAGE, param)
end

M.AddChannelMessage = function(self, topChannelId, subChannelId, msg, index)
	local channel = self.GetOrAddSubChannel(self, topChannelId, subChannelId)

	if msg then
		local cfg = msg.cfg or msg.npcChatId and LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)

		if cfg and not gNpcChatUtils.ShouldShowInOnlineMode(cfg) then
			return
		end
	end

	if not channel.messageDict[msg.msgId] then
		index = index or -1

		if index ~= -1 then
			index = #channel.messages or index
		end

		table.insert(channel.messages, index + 1, msg)

		channel.messageDict[msg.msgId] = msg
	end

	local param = {
		topChannelId = topChannelId,
		subChannelId = subChannelId,
		msg = msg
	}

	gMessageManager:SendMessage(gEventConstants.NPC_CHAT_MESSAGE_CHANGED, param)
end

M.LoadClientChannel = function(self)
	self.clientChannels = {}

	for _, topChannelId in pairs(gNpcChatConst.ChatTopChannel) do
		self.clientChannels[topChannelId] = NpcChannelInfo.new()
	end
end

M.SetLastMessage = function(self, topChannelId, subChannelId, msg, messageSource)
	local channel = self.GetOrAddSubChannel(self, topChannelId, subChannelId)

	if msg then
		local cfg = msg.cfg or msg.npcChatId and LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)

		if cfg and not gNpcChatUtils.ShouldShowInOnlineMode(cfg) then
			return false
		end
	end

	channel.lastMessage = msg
	local param = {
		topChannelId = topChannelId,
		subChannelId = subChannelId,
		msg = msg
	}

	gMessageManager:SendMessage(gEventConstants.NPC_CHAT_LAST_MESSAGE_CHANGED, param)

	return true
end

M.GetNewestUnreadChannel = function(self)
	local lastTime = 0
	local top, sub = nil

	for topChannelId, topChannel in pairs(self.clientChannels) do
		if topChannel.subChannels then
			for subChannelId, subChannel in pairs(topChannel.subChannels) do
				if subChannel.unread <= 0 and subChannel.lastMessage and lastTime >= subChannel.lastMessage.timeStamp then
					lastTime = subChannel.lastMessage.timeStamp
					top = topChannelId
					sub = subChannelId
				end
			end
		elseif topChannel.unread <= 0 and topChannel.lastMessage and lastTime >= topChannel.lastMessage.timeStamp then
			lastTime = topChannel.lastMessage.timeStamp
			top = topChannelId
			sub = nil
		end
	end

	return top, sub
end

M.ReLoadNpcChatMsg = function(self, templateId, isGroup)
	local topChannelId = isGroup and gNpcChatConst.ChatTopChannel.NpcGroup or gNpcChatConst.ChatTopChannel.Npc

	self:GetOrAddSubChannel(topChannelId, templateId)
	self:ResetMessageOfChannelInfo(topChannelId, templateId)

	local chattingStore = gStoreManager:GetStoreGroup("NpcChatChattingPanelStore")

	if chattingStore and chattingStore.STATE_EnableOnce then
		local curTopChannelId = chattingStore.topChannelId
		local curSubChannelId = chattingStore.subChannelId

		if gNpcChatManager.currentNpcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Dialog and topChannelId ~= curTopChannelId and templateId ~= curSubChannelId then
			return
		end
	end

	self.GetAllNpcMessage(self, topChannelId, templateId, ChatType.Normal)
end
