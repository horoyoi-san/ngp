-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\WaitUGuideAutoLocate.lua
-- Decompiled from: 00450_WaitUGuideAutoLocate.lua_88087c606983.luajit

C_GuideBT_WaitUGuideAutoLocate = DefClass("C_GuideBT_WaitUGuideAutoLocate", C_GuideBT_WaitUGuideAutoLocate, C_GuideBT_ActionBase)
local M = C_GuideBT_WaitUGuideAutoLocate

M.OnTick = function(self)
	local guideKey = self.guideId or self.guideKey

	if SGUI.GuideMgr.IsGuideKeyLocationRegistered(guideKey) and SGUI.GuideMgr.TryLocateDirect(guideKey, true) then
		return gGuideNodeState.Success
	end

	return gGuideNodeState.Running
end
