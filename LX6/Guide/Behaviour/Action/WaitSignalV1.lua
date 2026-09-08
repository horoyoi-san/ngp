-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\WaitSignalV1.lua
-- Decompiled from: 00448_WaitSignalV1.lua_52ead9965384.luajit

C_GuideBT_WaitSignalV1 = DefClass("C_GuideBT_WaitSignalV1", C_GuideBT_WaitSignalV1, C_GuideBT_ActionBase)
local M = C_GuideBT_WaitSignalV1

M.OnTick = function(self)
	if gNewGuideMgr:TryConsumeSignal(self.signal, self.realParam) then
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
