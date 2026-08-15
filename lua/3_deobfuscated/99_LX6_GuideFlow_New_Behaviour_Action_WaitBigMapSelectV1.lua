C_GuideBT_WaitBigMapSelectV1 = DefClass("C_GuideBT_WaitBigMapSelectV1", C_GuideBT_WaitBigMapSelectV1, C_GuideBT_ActionBase)
local M = C_GuideBT_WaitBigMapSelectV1

function M:OnTick()
	if not self._selected then
		return gGuideNodeState.Running
	else
		self._selected = nil

		return gGuideNodeState.Success
	end
end

function M:OnEnterRunning()
	self._selected = nil

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
		if param and param.gpsId == self.gpsId then
			self._selected = true
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.ON_BIG_MAP_SELECT, self._handler)
end

function M:ClearHandler()
	if not self._handler then
		return
	end

	gMessageManager:RemoveMessageListener(gEventConstants.ON_BIG_MAP_SELECT, self._handler)

	self._handler = nil
end
