-- Original chunk: @Lua\LuaFiles\LX6\Manager\ClientGameSwitch.lua
-- Decompiled from: 00162_ClientGameSwitch.lua_e495eafc911c.luajit

local M = {}

M.Sync = function(key, value)
	M[key] = value

	gMessageManager:SendMessage(gEventConstants.ON_GM_GAME_SWITCH_CHANGE)
end

gGameSwitch = M
