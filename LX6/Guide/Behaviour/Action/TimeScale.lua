-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\TimeScale.lua
-- Decompiled from: 00440_TimeScale.lua_0e547d9f07dc.luajit

C_GuideBT_TimeScale = DefClass("C_GuideBT_TimeScale", C_GuideBT_TimeScale, C_GuideBT_ActionBase)
local M = C_GuideBT_TimeScale

M.OnTick = function(self)
	return gGuideNodeState.Running
end

local GamePauseReason = UX.Game.GamePauseReason
local PauseManager = gCS.PauseManager

M.Run = function(self)
	local timeScale = self.timeScale:Eval()

	if gNewGuideMgr.globalPauseUUID ~= nil or timeScale == self.lastTimeScale then
		self:ResetTimeScale()

		gNewGuideMgr.globalPauseUUID = PauseManager.Instance:SetGlobalPause(GamePauseReason.Guide, timeScale, -1)
		self.lastTimeScale = timeScale
	end
end

M.OnExitRunning = function(self)
	self.ResetTimeScale(self)
end

M.ResetTimeScale = function(self)
	if gNewGuideMgr.globalPauseUUID then
		PauseManager.Instance:RemoveGlobalPause(gNewGuideMgr.globalPauseUUID)

		gNewGuideMgr.globalPauseUUID = nil
	end
end
