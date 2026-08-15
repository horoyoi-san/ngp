C_GuideBT_WaitTimer = DefClass("C_GuideBT_WaitTimer", C_GuideBT_WaitTimer, C_GuideBT_ActionBase)
local M = C_GuideBT_WaitTimer

function M:OnTick()
	local nextState = self.nextState

	if nextState then
		self.nextState = nil

		return nextState
	end

	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	if self.waitTimer and self.waitTimer > 0 then
		self._timer = Timer.New(function ()
			self.nextState = gGuideNodeState.Success
		end, self.waitTimer):Start()
	end
end

function M:OnExitRunning()
	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end
end
