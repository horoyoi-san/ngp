-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\WaitGpsTrace.lua
-- Decompiled from: 00445_WaitGpsTrace.lua_26fe67896f31.luajit

C_GuideBT_WaitGpsTrace = DefClass("C_GuideBT_WaitGpsTrace", C_GuideBT_WaitGpsTrace, C_GuideBT_ActionBase)
local M = C_GuideBT_WaitGpsTrace

M.OnTick = function(self)
	if not self._traced then
		return gGuideNodeState.Running
	else
		self._traced = nil

		return gGuideNodeState.Success
	end
end

M.OnEnterRunning = function(self)
	self._traced = nil

	self.AddHandler(self)
end

M.OnExitRunning = function(self)
	self.ClearHandler(self)
end

M.AddHandler = function(self)
	if self._handler then
		return
	end

	self._handler = function(eventId, param)
		local element = gMapSystem:GetByGpsId(self.gpsId)

		if not element then
			return
		end

		local instanceId = element.instanceId

		if param and param.newInstanceId and param.newInstanceId ~= instanceId then
			self._traced = true
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.ON_GLOBAL_GPS_UPDATE, self._handler)
end

M.ClearHandler = function(self)
	if not self._handler then
		return
	end

	gMessageManager:RemoveMessageListener(gEventConstants.ON_GLOBAL_GPS_UPDATE, self._handler)

	self._handler = nil
end
