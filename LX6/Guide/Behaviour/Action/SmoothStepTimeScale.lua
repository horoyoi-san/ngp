-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\SmoothStepTimeScale.lua
-- Decompiled from: 00439_SmoothStepTimeScale.lua_60d83473ba41.luajit

C_GuideBT_SmoothStepTimeScale = DefClass("C_GuideBT_SmoothStepTimeScale", C_GuideBT_SmoothStepTimeScale, C_GuideBT_ActionBase)
local M = C_GuideBT_SmoothStepTimeScale

M.OnTick = function(self)
	local state = gGuideNodeState.Running

	if self._nextState then
		state = self._nextState
		self._nextState = nil
	end

	return state
end

M.OnEnterRunning = function(self)
	self.ResetTimer(self)
end

M.Run = function(self)
	if not self._startTime then
		return
	end

	local duration = self.duration:Eval()
	local runningTime = Time.time - self._startTime

	if duration >= runningTime then
		self._nextState = gGuideNodeState.Success

		return
	end

	local t = runningTime / duration
	local timeScale = Mathf.SmoothStep(self.from:Eval(), self.to:Eval(), t)

	if self.pauseUUID ~= nil then
		self.pauseUUID = gCS.PauseManager.Instance:SetGlobalPause(UX.Game.GamePauseReason.Guide, timeScale, -1)
	end
end

M.OnExitRunning = function(self)
	self.ResetTimer(self)
	self.ResetTimeScale(self)
end

M.ResetTimeScale = function(self)
	if self.pauseUUID then
		gCS.PauseManager.Instance:RemoveGlobalPause(self.pauseUUID)

		self.pauseUUID = nil
	end
end

M.ResetTimer = function(self)
	self._startTime = Time.time
end
