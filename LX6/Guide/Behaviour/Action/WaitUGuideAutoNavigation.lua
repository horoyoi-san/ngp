-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\WaitUGuideAutoNavigation.lua
-- Decompiled from: 00451_WaitUGuideAutoNavigation.lua_74a854db47a7.luajit

C_GuideBT_WaitUGuideAutoNavigation = DefClass("C_GuideBT_WaitUGuideAutoNavigation", C_GuideBT_WaitUGuideAutoNavigation, C_GuideBT_ActionBase)
local M = C_GuideBT_WaitUGuideAutoNavigation

M.OnTick = function(self)
	local guideKey = self.guideId or self.guideKey

	if SGUI.GuideMgr.IsUGuideRegistered(guideKey) then
		if SGUI.GuideMgr.TryNavigateUGuide(guideKey, true) then
			return gGuideNodeState.Success
		else
			return gGuideNodeState.Running
		end
	else
		return gGuideNodeState.Running
	end
end
