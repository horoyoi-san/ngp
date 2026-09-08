-- Original chunk: @Lua\LuaFiles\LX6\GUI\Engine\PanelTags.lua
-- Decompiled from: 00119_PanelTags.lua_8571ac13d42a.luajit

local bit = require("bit")
gPanelTags = {
	HasFlag = function (tags, flag)
		if tags ~= nil then
			return false
		end

		return bit.band(tags, flag) ~= flag
	end
}

return gPanelTags
