-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\SetBigMapInterest.lua
-- Decompiled from: 00426_SetBigMapInterest.lua_91ea6093018a.luajit

C_GuideBT_SetBigMapInterest = DefClass("C_GuideBT_SetBigMapInterest", C_GuideBT_SetBigMapInterest, C_GuideBT_ActionBase)
local M = C_GuideBT_SetBigMapInterest

M.DoTick = function(self)
	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	if string.is_null_or_empty(self.gpsId) then
		return
	end

	self.instanceId = gMapSystem:GetInstanceIdByGpsId(self.gpsId)

	gMapSystem.ui:SetBigMapGuideInterest(self.instanceId)
end

M.OnExitRunning = function(self)
	if not self.instanceId then
		return
	end

	gMapSystem.ui:ClearBigMapGuideInterest(self.instanceId)
end
