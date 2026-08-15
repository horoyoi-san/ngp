local ChatTopChannel = gNpcChatConst.ChatTopChannel
local NpcChatTopChannelInfo = {
	new = function ()
		local self = {
			auxiliaryChannel = nil,
			hide = false,
			redirectChannel = nil
		}

		return self
	end
}
C_NpcChatTabs = DefClass("C_NpcChatTabs", C_NpcChatTabs)
local M = C_NpcChatTabs

function M:ctor()
	self.topChannelInfo = {}

	self:InitData()
end

function M:InitData()
	local npcInfo = NpcChatTopChannelInfo.new()
	npcInfo.auxiliaryChannel = {
		ChatTopChannel.NpcGroup
	}
	npcInfo.redirectChannel = 0
	self.topChannelInfo[ChatTopChannel.Npc] = npcInfo
	local npcGroupInfo = NpcChatTopChannelInfo.new()
	npcGroupInfo.hide = true
	npcGroupInfo.redirectChannel = ChatTopChannel.Npc
	self.topChannelInfo[ChatTopChannel.NpcGroup] = npcGroupInfo
end

NpcChatTabs = C_NpcChatTabs.new()

return NpcChatTabs
