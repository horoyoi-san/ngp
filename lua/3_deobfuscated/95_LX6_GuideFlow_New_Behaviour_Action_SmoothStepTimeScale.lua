C_GuideBT_SmoothStepTimeScale = DefClass("C_GuideBT_SmoothStepTimeScale", C_GuideBT_SmoothStepTimeScale, C_GuideBT_ActionBase)
local M = C_GuideBT_SmoothStepTimeScale

function M:OnTick()
	local state = gGuideNodeState.Running

	if self._nextState then
		state = self._nextState
		self._nextState = nil
	end

	return state
end

function M:OnEnterRunning()
	self:ResetTimer()
end

function M:Run()
	if not self._startTime then
		return
	end

	local duration = self.duration:Eval()
	local runningTime = Time.time - self._startTime

	if duration < runningTime then
		self._nextState = gGuideNodeState.Success

		return
	end

	local t = runningTime / duration
	local timeScale = Mathf.SmoothStep(self.from:Eval(), self.to:Eval(), t)

	if self.pauseUUID == nil then
		self.pauseUUID = gCS.PauseManager.Instance:SetGlobalPause(UX.Game.GamePauseReason.Guide, timeScale, -1)
	end
end

function M:OnExitRunning()
	self:ResetTimer()
	self:ResetTimeScale()
end

function M:ResetTimeScale()
	if self.pauseUUID then
		gCS.PauseManager.Instance:RemoveGlobalPause(self.pauseUUID)

		self.pauseUUID = nil
	end
end

function M:ResetTimer()
	self._startTime = Time.time
end
