local ChatType = LTConfig.NPCChatConfig.ChatTypeType
local SexType = UX.Game.SexType
local M = C_NpcChatManager

function M:SetUnreadCount(topChannelId, subChannelId, count)
	local channel = self:GetChannel(topChannelId, subChannelId)

	if not channel or channel.unread == count then
		return
	end

	channel.unread = count
	local param = {
		topChannelId = topChannelId,
		subChannelId = subChannelId,
		count = count
	}

	if self:CheckIsShowRedPoint(channel) then
		gMessageManager:SendMessage(gEventConstants.UPDATE_UNREAD_MSG_TIPS, param)
	end
end

function M:UpdateUnreadMsgCount(msg, isHistory)
	local topChannelId = msg.topChannelId
	local subChannelId = msg.subChannelId

	if not isHistory then
		if self:IsCurrentChannel(topChannelId, msg.subChannelId) then
			self:ReadNpcChat(topChannelId, subChannelId)
		else
			self:UnReadNpcChat(topChannelId, subChannelId)
		end
	end

	local isUnread = self:IsUnReadNpcChat(topChannelId, subChannelId)
	local hasNext = gNpcChatUtils.HasNextMessage(msg)
	local count = (isUnread or hasNext) and 1 or 0

	self:SetUnreadCount(topChannelId, msg.subChannelId, count)
end

function M:GetUnreadCount(topChannelId, subChannelId)
	local ret = 0
	local channel = self:GetChannel(topChannelId, subChannelId)

	if channel then
		if self:CheckIsShowRedPoint(channel) then
			ret = ret + channel.unread
		end

		if channel.subChannels then
			for _, subChannel in pairs(channel.subChannels) do
				if self:CheckIsShowRedPoint(subChannel) then
					ret = ret + subChannel.unread
				end
			end
		end
	end

	if not subChannelId and NpcChatTabs.topChannelInfo[topChannelId] then
		local channelInfo = NpcChatTabs.topChannelInfo[topChannelId]

		if channelInfo.auxiliaryChannel then
			for _, auxiliaryChannel in ipairs(channelInfo.auxiliaryChannel) do
				ret = ret + self:GetUnreadCount(auxiliaryChannel)
			end
		end
	end

	return ret
end

function M:CheckIsShowRedPoint(channel)
	if channel.topChannelId ~= gNpcChatConst.ChatTopChannel.Npc or channel.unread == 0 then
		return true
	end

	if not channel.messages or #channel.messages == 0 then
		return true
	end

	local cfg = LTConfig.NPCChatConfig.GetConfig(channel.messages[1].npcChatId)

	if not cfg then
		return true
	end

	if cfg.ChatType ~= ChatType.Dialog then
		return gNpcChatUtils.IsVisibleToCurrentNpc(channel.messages[1].npcChatId)
	end

	return true
end

function M:GetAsNpcCultivation(asNpcCultivation)
	if asNpcCultivation ~= 1 then
		return asNpcCultivation
	end

	if gCS.MyPlayerManager.PlayerInfo.SexType == SexType.Male then
		return LTConfig.NpcCultivationConfig.DefaultMale
	else
		return LTConfig.NpcCultivationConfig.DefaultFemale
	end
end

function M:GetTotalUnreadCount()
	local total = 0
	local topChannelInfo = NpcChatTabs.topChannelInfo

	for channelId, _ in pairs(self.clientChannels) do
		if not topChannelInfo[channelId] or not topChannelInfo[channelId].hide then
			total = total + self:GetUnreadCount(channelId)
		end
	end

	return total
end

function M:ResetUnreadCount(topChannelId, subChannelId, force)
	if self:GetUnreadCount(topChannelId, subChannelId) == 0 and not force then
		return
	end

	self:ReadNpcChat(topChannelId, subChannelId)

	local channel = self:GetChannel(topChannelId, subChannelId)
	local hasNext = channel.lastMessage and gNpcChatUtils.HasNextMessage(channel.lastMessage)
	local count = hasNext and 1 or 0

	self:SetUnreadCount(topChannelId, subChannelId, count)
end
