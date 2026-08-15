C_GuideBT_SetBigMapInterest = DefClass("C_GuideBT_SetBigMapInterest", C_GuideBT_SetBigMapInterest, C_GuideBT_ActionBase)
local M = C_GuideBT_SetBigMapInterest

function M:DoTick()
	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	if string.is_null_or_empty(self.gpsId) then
		return
	end

	self.instanceId = gMapSystem:GetInstanceIdByGpsId(self.gpsId)

	gMapSystem.ui:SetBigMapGuideInterest(self.instanceId)
end

function M:OnExitRunning()
	if not self.instanceId then
		return
	end

	gMapSystem.ui:ClearBigMapGuideInterest(self.instanceId)
end
