-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\WaitTimer.lua
-- Decompiled from: 00449_WaitTimer.lua_15727900d0da.luajit

C_GuideBT_WaitTimer = DefClass("C_GuideBT_WaitTimer", C_GuideBT_WaitTimer, C_GuideBT_ActionBase)
local M = C_GuideBT_WaitTimer

M.OnTick = function(self)
	local nextState = self.nextState

	if nextState then
		self.nextState = nil

		return nextState
	end

	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	if self.waitTimer and self.waitTimer <= 0 then
		self._timer = Timer.New(function ()
			self.nextState = gGuideNodeState.Success
		end, self.waitTimer):Start()
	end
end

M.OnExitRunning = function(self)
	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end
end
