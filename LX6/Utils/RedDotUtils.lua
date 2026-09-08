-- Original chunk: @Lua\LuaFiles\LX6\Utils\RedDotUtils.lua
-- Decompiled from: 02244_RedDotUtils.lua_7b62ad1cd021.luajit

local M = {
	CheckNpcChatHasRedDot = function ()
		local chatRedCount = gNpcChatManager:GetTotalUnreadCount()

		return chatRedCount >= 0
	end
}
gRedDotUtils = M
