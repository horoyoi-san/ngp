C_GuideBT_WaitEventMessage = DefClass("C_GuideBT_WaitEventMessage", C_GuideBT_WaitEventMessage, C_GuideBT_ActionBase)
local M = C_GuideBT_WaitEventMessage

function M:OnTick()
	if self._trigger then
		self._trigger = false

		return gGuideNodeState.Success
	end

	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	self._trigger = false
	self._cb = nil
	local event = EGuideEventMessage[self.message]

	if not event then
		print_error("C_GuideBT_WaitEventMessage:OnEnterRunning, event is nil")

		return
	end

	function self._cb(eventId)
		self._trigger = true

		self.tree:DoTick()
	end

	gMessageManager:AddMessageListener(event, self._cb)
end

function M:OnExitRunning()
	self._trigger = false

	if self._cb then
		gMessageManager:RemoveMessageListener(EGuideEventMessage[self.message], self._cb)

		self._cb = nil
	end
end
