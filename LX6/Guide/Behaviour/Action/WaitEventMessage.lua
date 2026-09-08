-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\WaitEventMessage.lua
-- Decompiled from: 00443_WaitEventMessage.lua_d8b12da2c475.luajit

C_GuideBT_WaitEventMessage = DefClass("C_GuideBT_WaitEventMessage", C_GuideBT_WaitEventMessage, C_GuideBT_ActionBase)
local M = C_GuideBT_WaitEventMessage

M.OnTick = function(self)
	if self._trigger then
		self._trigger = false

		return gGuideNodeState.Success
	end

	return gGuideNodeState.Running
end

M.OnEnterRunning = function(self)
	self._trigger = false
	self._cb = nil
	local event = EGuideEventMessage[self.message]

	if not event then
		print_error("C_GuideBT_WaitEventMessage:OnEnterRunning, event is nil")

		return
	end

	self._cb = function(eventId)
		self._trigger = true

		self.tree:DoTick()
	end

	gMessageManager:AddMessageListener(event, self._cb)
end

M.OnExitRunning = function(self)
	self._trigger = false

	if self._cb then
		gMessageManager:RemoveMessageListener(EGuideEventMessage[self.message], self._cb)

		self._cb = nil
	end
end
