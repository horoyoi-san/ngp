-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\WaitPanelOpen.lua
-- Decompiled from: 00446_WaitPanelOpen.lua_204bfc1b25c5.luajit

C_GuideBT_WaitPanelOpen = DefClass("C_GuideBT_WaitPanelOpen", C_GuideBT_WaitPanelOpen, C_GuideBT_ActionBase)
local M = C_GuideBT_WaitPanelOpen

M.OnTick = function(self)
	if gPanelManager:IsPanelShowing(self.panelId) then
		return gGuideNodeState.Success
	else
		return gGuideNodeState.Running
	end
end
