-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\ShowBackground.lua
-- Decompiled from: 00431_ShowBackground.lua_7c7b3e89d526.luajit

C_GuideBT_ShowBackground = DefClass("C_GuideBT_ShowBackground", C_GuideBT_ShowBackground, C_GuideBT_ActionBase)
local M = C_GuideBT_ShowBackground

M.OnCreate = function(self)
	self._bgHandle = 0
end

M.OnEnterRunning = function(self)
	self._bgHandle = SGUI.GuideMgr.BTShowBackground(self.backgroundColor)
end

M.OnExitRunning = function(self)
	if self._bgHandle == 0 then
		SGUI.GuideMgr.BTHideBackground(self._bgHandle)

		self._bgHandle = 0
	end
end

M.OnTick = function(self)
	return gGuideNodeState.Running
end
