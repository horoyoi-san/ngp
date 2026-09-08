-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\WaitUGuideAutoSelected.lua
-- Decompiled from: 00452_WaitUGuideAutoSelected.lua_e609e2c45e05.luajit

C_GuideBT_WaitUGuideAutoSelected = DefClass("C_GuideBT_WaitUGuideAutoSelected", C_GuideBT_WaitUGuideAutoSelected, C_GuideBT_ActionBase)
local M = C_GuideBT_WaitUGuideAutoSelected

M.OnTick = function(self)
	local guideKey = self.guideId or self.guideKey

	if SGUI.GuideMgr.IsUGuideRegistered(guideKey) then
		if SGUI.GuideMgr.TrySelectUGuide(guideKey) then
			return gGuideNodeState.Success
		else
			return gGuideNodeState.Failure
		end
	else
		return gGuideNodeState.Running
	end
end
