-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\WaitSignal.lua
-- Decompiled from: 00447_WaitSignal.lua_f338e021c4b0.luajit

C_GuideBT_WaitSignal = DefClass("C_GuideBT_WaitSignal", C_GuideBT_WaitSignal, C_GuideBT_ActionBase)
local M = C_GuideBT_WaitSignal

M.OnTick = function(self)
	if gNewGuideMgr:TryConsumeSignal(EGuideSignal[self.signal], self.realParam) then
		return gGuideNodeState.Success
	else
		return gGuideNodeState.Running
	end
end

M.OnEnterRunning = function(self)
	if not string.is_null_or_empty(self.param) then
		self.realParam = self.param
	else
		self.realParam = nil
	end
end
