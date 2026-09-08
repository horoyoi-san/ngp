-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\UGuideAutoNavigation.lua
-- Decompiled from: 00441_UGuideAutoNavigation.lua_bb80aeedbd1e.luajit

C_GuideBT_UGuideAutoNavigation = DefClass("C_GuideBT_UGuideAutoNavigation", C_GuideBT_UGuideAutoNavigation, C_GuideBT_ActionBase)
local M = C_GuideBT_UGuideAutoNavigation

M.OnTick = function(self)
	local guideKey = self.guideId or self.guideKey

	if SGUI.GuideMgr.IsUGuideRegistered(guideKey) then
		if SGUI.GuideMgr.TryNavigateUGuide(guideKey, true) then
			return gGuideNodeState.Success
		else
			return gGuideNodeState.Failure
		end
	else
		return gGuideNodeState.Failure
	end
end
