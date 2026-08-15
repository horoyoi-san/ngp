C_GuideBT_TimeScale = DefClass("C_GuideBT_TimeScale", C_GuideBT_TimeScale, C_GuideBT_ActionBase)
local M = C_GuideBT_TimeScale

function M:OnTick()
	return gGuideNodeState.Running
end

local GamePauseReason = UX.Game.GamePauseReason
local PauseManager = gCS.PauseManager

function M:Run()
	local timeScale = self.timeScale:Eval()

	if gNewGuideMgr.globalPauseUUID == nil or timeScale ~= self.lastTimeScale then
		self:ResetTimeScale()

		gNewGuideMgr.globalPauseUUID = PauseManager.Instance:SetGlobalPause(GamePauseReason.Guide, timeScale, -1)
		self.lastTimeScale = timeScale
	end
end

function M:OnExitRunning()
	self:ResetTimeScale()
end

function M:ResetTimeScale()
	if gNewGuideMgr.globalPauseUUID then
		PauseManager.Instance:RemoveGlobalPause(gNewGuideMgr.globalPauseUUID)

		gNewGuideMgr.globalPauseUUID = nil
	end
end
