C_GuideBT_WaitGpsTrace = DefClass("C_GuideBT_WaitGpsTrace", C_GuideBT_WaitGpsTrace, C_GuideBT_ActionBase)
local M = C_GuideBT_WaitGpsTrace

function M:OnTick()
	if not self._traced then
		return gGuideNodeState.Running
	else
		self._traced = nil

		return gGuideNodeState.Success
	end
end

function M:OnEnterRunning()
	self._traced = nil

	self:AddHandler()
end

function M:OnExitRunning()
	self:ClearHandler()
end

function M:AddHandler()
	if self._handler then
		return
	end

	function self._handler(eventId, param)
		local element = gMapSystem:GetByGpsId(self.gpsId)

		if not element then
			return
		end

		local instanceId = element.instanceId

		if param and param.newInstanceId and param.newInstanceId == instanceId then
			self._traced = true
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.ON_GLOBAL_GPS_UPDATE, self._handler)
end

function M:ClearHandler()
	if not self._handler then
		return
	end

	gMessageManager:RemoveMessageListener(gEventConstants.ON_GLOBAL_GPS_UPDATE, self._handler)

	self._handler = nil
end
