-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\Base\MiniGameUtils.lua
-- Decompiled from: 00584_MiniGameUtils.lua_f3e62e0558f2.luajit

gMiniGameUtils = gMiniGameUtils or {}
local MiniGameUtils = gMiniGameUtils

MiniGameUtils.SetPlayerUnitVisible = function(visible)
	local myUnit = gCS.MyPlayerManager.PlayerUnit

	if gCS.LuaUtils.IsBaseUnitValid(myUnit) then
		local invisible = not visible
		myUnit.InvisibleToAll = invisible
		myUnit.Invisible = invisible

		gCS.BaseUnitUtils.SetUnitLogicalHidden(myUnit, invisible, LX6.Units.LogicalHiddenCause.GamePlay)
	end
end
