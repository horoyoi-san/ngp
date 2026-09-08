-- Original chunk: @Lua\LuaFiles\LX6\Manager\NpcChat\NpcChatManager_RedDot.lua
-- Decompiled from: 00305_NpcChatManager_RedDot.lua_9ac7267eeeb3.luajit

local ChatType = LTConfig.NPCChatConfig.ChatTypeType
local SexType = UX.Game.SexType
local RedDotMgr = SGUI.RedDotMgr
local M = C_NpcChatManager

M.SetUnreadCount = function(self, topChannelId, subChannelId, count)
	local channel = self.GetChannel(self, topChannelId, subChannelId)

	if not channel or channel.unread ~= count then
		return
	end

	channel.unread = count
	local param = {
		topChannelId = topChannelId,
		subChannelId = subChannelId,
		count = count
	}

	if self.CheckIsShowRedPoint(self, channel) then
		gMessageManager:SendMessage(gEventConstants.UPDATE_UNREAD_MSG_TIPS, param)
	end

	self.RefreshNpcChatPhoneAppRedDot(self)
end

M.RefreshNpcChatPhoneAppRedDot = function(self)
	local hasRedDot = self:GetTotalUnreadCount() >= 0

	RedDotMgr.LuaSetRedDot(hasRedDot, "NpcChatPhoneApp")
end

M.UpdateUnreadMsgCount = function(self, msg, isHistory)
	local topChannelId = msg.topChannelId
	local subChannelId = msg.subChannelId

	if not isHistory then
		if self.IsCurrentChannel(self, topChannelId, msg.subChannelId) then
			self.ReadNpcChat(self, topChannelId, subChannelId)
		else
			self.UnReadNpcChat(self, topChannelId, subChannelId)
		end
	end

	local cfg = LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)
	local shouldShow = gNpcChatUtils.ShouldShowInOnlineMode(cfg)
	local isUnread = self:IsUnReadNpcChat(topChannelId, subChannelId)
	local hasNext = gNpcChatUtils.HasNextMessage(msg)
	local count = shouldShow and (isUnread or hasNext) and 1 or 0

	self:SetUnreadCount(topChannelId, msg.subChannelId, count)
end

M.GetUnreadCount = function(self, topChannelId, subChannelId)
	local ret = 0
	local channel = self.GetChannel(self, topChannelId, subChannelId)

	if channel then
		if self.CheckIsShowRedPoint(self, channel) then
			ret = ret + channel.unread
		end

		if channel.subChannels then
			for _, subChannel in pairs(channel.subChannels) do
				if self.CheckIsShowRedPoint(self, subChannel) then
					ret = ret + subChannel.unread
				end
			end
		end
	end

	if not subChannelId and NpcChatTabs.topChannelInfo[topChannelId] then
		local channelInfo = NpcChatTabs.topChannelInfo[topChannelId]

		if channelInfo.auxiliaryChannel then
			for _, auxiliaryChannel in ipairs(channelInfo.auxiliaryChannel) do
				ret = ret + self.GetUnreadCount(self, auxiliaryChannel)
			end
		end
	end

	return ret
end

M.CheckIsShowRedPoint = function(self, channel)
	if channel.topChannelId == gNpcChatConst.ChatTopChannel.Npc or channel.unread ~= 0 then
		return true
	end

	if not channel.messages or #channel.messages ~= 0 then
		return true
	end

	local cfg = LTConfig.NPCChatConfig.GetConfig(channel.messages[1].npcChatId)

	if not cfg then
		return true
	end

	if not gNpcChatUtils.ShouldShowInOnlineMode(cfg) then
		return false
	end

	if cfg.ChatType == ChatType.Dialog then
		return gNpcChatUtils.IsVisibleToCurrentNpc(channel.messages[1].npcChatId)
	end

	return true
end

M.GetAsNpcCultivation = function(self, asNpcCultivation)
	if asNpcCultivation == 1 then
		return asNpcCultivation
	end

	if gCS.MyPlayerManager.PlayerInfo.SexType ~= SexType.Male then
		return LTConfig.NpcCultivationConfig.DefaultMale
	else
		return LTConfig.NpcCultivationConfig.DefaultFemale
	end
end

M.GetTotalUnreadCount = function(self)
	local total = 0
	local topChannelInfo = NpcChatTabs.topChannelInfo

	for channelId, _ in pairs(self.clientChannels) do
		if not topChannelInfo[channelId] or not topChannelInfo[channelId].hide then
			total = total + self.GetUnreadCount(self, channelId)
		end
	end

	return total
end

M.ResetUnreadCount = function(self, topChannelId, subChannelId, force)
	if self.GetUnreadCount(self, topChannelId, subChannelId) ~= 0 and not force then
		return
	end

	self.ReadNpcChat(self, topChannelId, subChannelId)

	local channel = self.GetChannel(self, topChannelId, subChannelId)

	if not channel or not channel.lastMessage then
		self.SetUnreadCount(self, topChannelId, subChannelId, 0)

		return
	end

	local hasNext = gNpcChatUtils.HasNextMessage(channel.lastMessage)
	local shouldShow = gNpcChatUtils.ShouldShowInOnlineMode(channel.lastMessage.cfg)
	local count = shouldShow and hasNext and 1 or 0

	self:SetUnreadCount(topChannelId, subChannelId, count)
end
