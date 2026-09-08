-- Original chunk: @Lua\LuaFiles\LX6\Manager\NpcChat\NpcChatTabs.lua
-- Decompiled from: 00301_NpcChatTabs.lua_ff6cd5e39b45.luajit

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

M.ctor = function(self)
	self.topChannelInfo = {}

	self.InitData(self)
end

M.InitData = function(self)
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
