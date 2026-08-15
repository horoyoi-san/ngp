local ChatType = LTConfig.NPCChatConfig.ChatTypeType
NpcChannelInfo = DefClass("NpcChannelInfo", NpcChannelInfo)

function NpcChannelInfo:ctor()
	self.topChannelId = 0
	self.subChannelId = 0
	self.messages = {}
	self.messageDict = {}
	self.unread = 0
	self.subChannels = {}
	self.lastMessage = nil
end

local M = C_NpcChatManager

function M:Init_Channel()
	self.clientChannels = {}
end

function M:GetChannel(topChannelId, subChannelId)
	local topChannel = self.clientChannels[topChannelId]

	if not topChannel then
		return nil
	end

	if not subChannelId then
		return topChannel
	end

	return topChannel.subChannels and topChannel.subChannels[subChannelId]
end

function M:GetOrAddSubChannel(topChannelId, subChannelId)
	local channel = self:GetChannel(topChannelId, subChannelId)

	if not channel then
		return self:InsertSubChannel(topChannelId, subChannelId, NpcChannelInfo.new())
	end

	return channel
end

function M:InsertSubChannel(topChannelId, subChannelId, channelInfo)
	local topChannel = self:GetChannel(topChannelId)

	if not topChannel or subChannelId == 0 then
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

function M:ResetMessageOfChannelInfo(topChannelId, subChannelId)
	local channel = self:GetChannel(topChannelId, subChannelId)

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

function M:AddChannelMessage(topChannelId, subChannelId, msg, index)
	local channel = self:GetOrAddSubChannel(topChannelId, subChannelId)

	if not channel.messageDict[msg.msgId] then
		index = index or -1

		if index == -1 then
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

function M:LoadClientChannel()
	self.clientChannels = {}

	for _, topChannelId in pairs(gNpcChatConst.ChatTopChannel) do
		self.clientChannels[topChannelId] = NpcChannelInfo.new()
	end
end

function M:SetLastMessage(topChannelId, subChannelId, msg, messageSource)
	local channel = self:GetOrAddSubChannel(topChannelId, subChannelId)
	channel.lastMessage = msg
	local param = {
		topChannelId = topChannelId,
		subChannelId = subChannelId,
		msg = msg
	}

	gMessageManager:SendMessage(gEventConstants.NPC_CHAT_LAST_MESSAGE_CHANGED, param)

	return true
end

function M:GetNewestUnreadChannel()
	local lastTime = 0
	local top, sub = nil

	for topChannelId, topChannel in pairs(self.clientChannels) do
		if topChannel.subChannels then
			for subChannelId, subChannel in pairs(topChannel.subChannels) do
				if subChannel.unread > 0 and subChannel.lastMessage and lastTime < subChannel.lastMessage.timeStamp then
					lastTime = subChannel.lastMessage.timeStamp
					top = topChannelId
					sub = subChannelId
				end
			end
		elseif topChannel.unread > 0 and topChannel.lastMessage and lastTime < topChannel.lastMessage.timeStamp then
			lastTime = topChannel.lastMessage.timeStamp
			top = topChannelId
			sub = nil
		end
	end

	return top, sub
end

function M:ReLoadNpcChatMsg(templateId, isGroup)
	local topChannelId = isGroup and gNpcChatConst.ChatTopChannel.NpcGroup or gNpcChatConst.ChatTopChannel.Npc

	self:GetOrAddSubChannel(topChannelId, templateId)
	self:ResetMessageOfChannelInfo(topChannelId, templateId)
	self:GetAllNpcMessage(topChannelId, templateId, ChatType.Normal)
end
